//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import Foundation

public final class BrewExtension {

    public typealias Formulaes = Graph<String, FormulaeInfo>
    public typealias Labels = [String: Set<String>]

    public internal(set) var brew: Brew
    public weak var dataSource: BrewExtensionDataSource? {
        didSet {
            try! self.dataSource?.load()
        }
    }

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.brew = Brew(url: url)
    }

    // MARK: Sync with data base

    /// Sync formulae info with homebrew
    ///
    /// - Throws:
    public func sync() throws {
        guard let dataSource = self.dataSource else { return }

        let list = try self.brew.list()
        let rawInfos = try self.brew.info(of: list)

        var formulaes = Formulaes()

        for info in rawInfos {
            // TODO: init formulae info
            formulaes.insert(info.name, with: FormulaeInfo())
        }

        // build connections

        for info in rawInfos {
            let name = info.name

            for dep in info.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if formulaes.contains(dep) {
                    formulaes.connect(from: name, to: dep)
                }
            }
        }

        // Merge formulae infos

        for existingFormulae in dataSource.formulaes {
            formulaes[existingFormulae.node] = existingFormulae.data
        }

        dataSource.formulaes = formulaes
        try dataSource.flush()
    }

    public func load() throws {
        try self.dataSource?.load()
    }

    // MARK: Uninstall

    public func findFormulaesToUninstall(for formulae: String) -> [String] {
        guard let formulaes = self.dataSource?.formulaes else { return [] }
        guard formulaes.contains(formulae) else { return [] }

        var uninstalls = [String]()
        var graph = formulaes
        var set = Set<String>()
        set.insert(formulae)

        while let current = set.popFirst() {
            let incomings = graph.incomings(for: current)!
            let data = graph.data(for: current)!

            guard incomings.isEmpty else { continue }

            if (data.isUserPackage && current == formulae) || !data.isUserPackage {
                let outcomings = graph.outcomings(for: current)!

                for outcoming in outcomings {
                    if !set.contains(outcoming) {
                        set.insert(outcoming)
                    }
                }

                graph.remove(current)
                uninstalls.append(current)
            }
        }

        return uninstalls
    }

    public func uninstallFormulae(_ formulae: String) throws {
        guard let dataSource = self.dataSource else { return }

        let formulaes = dataSource.formulaes
        guard formulaes.contains(formulae) else { return }
        
        let data = formulaes.data(for: formulae)!

        for label in data.labels {
            dataSource.labels[label]!.remove(formulae)
        }

        dataSource.formulaes.remove(formulae)
        try dataSource.flush()

        try self.brew.uninstallFormulae(formulae)
    }

    // MARK: List

    public func formulaes() -> [String] {
        guard let dataSource = self.dataSource else { return [] }

        var list = [String]()

        for formulae in dataSource.formulaes {
            list.append(formulae.node)
        }

        return list
    }

    public func formulaes(under label: String) -> [String] {
        guard let dataSource = self.dataSource else { return [] }
        guard let formulaes = dataSource.labels[label] else { return [] }

        return .init(formulaes)
    }

    // MARK: Label

    public func removeLabel(_ label: String) throws {
        guard let dataSource = self.dataSource else { return }
        guard let formulaesInLabel = dataSource.labels[label] else { return }

        for formulae in formulaesInLabel {
            dataSource.formulaes[formulae]!.labels.remove(label)
        }

        dataSource.labels.removeValue(forKey: label)
        try dataSource.flush()
    }

    public func labelFormulae(
        _ formulae: String,
        as label: String) throws {

        guard let dataSource = self.dataSource else { return }

        if dataSource.labels[label] == nil {
            dataSource.labels[label] = .init([formulae])
        } else {
            dataSource.labels[label]!.insert(formulae)
        }

        dataSource.formulaes[formulae]!.labels.insert(label)
        try dataSource.flush()
    }

    public func removeLabel(_ label: String, from formulae: String) throws {
        guard let dataSource = self.dataSource else { return }

        dataSource.labels[label]?.remove(formulae)
        dataSource.formulaes[formulae]?.labels.remove(label)

        try dataSource.flush()
    }
}
