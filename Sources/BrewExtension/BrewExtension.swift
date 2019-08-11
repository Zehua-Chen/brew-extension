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
    public internal(set) var formulaes = Formulaes()

    public typealias Labels = [String: Set<String>]
    public internal(set) var labels = Labels()

    public internal(set) var brew: Brew
    public weak var dataSource: BrewExtensionDataSource?

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
        let list = try self.brew.list()
        let rawInfos = try self.brew.info(of: list)

        self.formulaes = .init()

        for info in rawInfos {
            // TODO: init formulae info
            self.formulaes.insert(info.name, with: FormulaeInfo())
        }

        // build connections

        for info in rawInfos {
            let name = info.name

            for dep in info.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if self.formulaes.contains(dep) {
                    self.formulaes.connect(from: name, to: dep)
                }
            }
        }

        // Merge formulae infos

        guard let existingFormulaes = try self.dataSource?.loadFormulaes() else {
            return
        }

        for existingFormulae in existingFormulaes {
            self.formulaes[existingFormulae.node] = existingFormulae.data
        }

        try self.dataSource?.saveFormulaes(self.formulaes)
    }

    /// Sync the information of the brew extension into a database
    ///
    /// - Parameter db: the data base to write into
    public func flush() throws {
        try self.dataSource?.saveFormulaes(self.formulaes)
        try self.dataSource?.saveLabels(self.labels)
    }

    public func load() throws {
        if let formulaes = try self.dataSource?.loadFormulaes() {
            self.formulaes = formulaes
        }

        if let labels = try self.dataSource?.loadLabels() {
            self.labels = labels
        }
    }

    // MARK: Uninstall

    public func findFormulaesToUninstall(for formulae: String) -> [String] {
        guard self.formulaes.contains(formulae) else { return [] }

        var uninstalls = [String]()
        var graph = self.formulaes
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
        guard self.formulaes.contains(formulae) else { return }
        let data = self.formulaes.data(for: formulae)!

        for label in data.labels {
            // Remove the formulae in folders
            self.labels[label]?.remove(formulae)
        }

        self.formulaes.remove(formulae)
        try self.dataSource?.removeFormulae(formulae)
    }

    // MARK: Folder

    public func removeLable(_ labels: String) throws {
        guard let formulaes = self.labels[labels] else { return }

        for formulae in formulaes {
            try self.uninstallFormulae(formulae)
        }

        try self.dataSource?.removeLabel(labels)
    }

    public func labelFormulae<DB: BrewExtensionDataSource>(
        _ formulae: String,
        as label: String,
        db: inout DB) throws {

        self.labels[label]?.insert(formulae)
        try db.labelFormulae(formulae, as: label)
    }
}
