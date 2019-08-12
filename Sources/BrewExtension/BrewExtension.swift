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
    internal var _formulaes = Graph<String, FormulaeInfo>()

    public weak var dataBase: BrewExtensionDataBase? {
        didSet {
            guard let db = self.dataBase else { return }

            _formulaes = .init()

            let formulaes = db.formulaes()

            for formulae in formulaes {
                let protected = db.protectsFormulae(formulae)
                let labels = db.labels(of: formulae)
                _formulaes.insert(formulae, with: .init(
                    isProtected: protected,
                    labels: labels))
            }

            for formulae in formulaes {
                let outcomings = db.outcomingDependencies(for: formulae)

                for outcoming in outcomings {
                    _formulaes.connect(from: formulae, to: outcoming)
                }
            }
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
    /// - Parameter providedRawInfos: the raw info of home-brew used to sync
    public func sync(using providedRawInfos: [Brew.FormulaeInfo]? = nil) throws {
        let list = try self.brew.list()
        let rawInfos: [Brew.FormulaeInfo]

        if providedRawInfos != nil {
            rawInfos = providedRawInfos!
        } else {
            rawInfos = try self.brew.info(of: list)
        }

        _formulaes = Formulaes()

        for info in rawInfos {
            // TODO: init formulae info
            _formulaes.insert(info.name, with: FormulaeInfo())

            if !(self.dataBase?.containsFormulae(info.name) ?? false) {
                self.dataBase?.addFormulae(info.name)
            }
        }

        // build connections

        for info in rawInfos {
            let name = info.name

            for dep in info.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if _formulaes.contains(dep) {
                    _formulaes.connect(from: name, to: dep)
                }

                if let dataBase = self.dataBase {
                    if dataBase.containsFormulae(dep) && !dataBase.hasDependency(from: name, to: dep) {
                        dataBase.addDependency(from: name, to: dep)
                    }
                }
            }
        }

        // Merge formulae infos

        for formulae in _formulaes {
            let protected = self.dataBase?.protectsFormulae(formulae.node) ?? false
            let labels = self.dataBase?.labels(of: formulae.node) ?? Set<String>()

            _formulaes[formulae.node] = .init(isProtected: protected, labels: labels)
        }

        self.dataBase?.write()
    }

    // MARK: Uninstall

    public func findFormulaesToUninstall(for formulae: String) -> [String] {
        guard _formulaes.contains(formulae) else { return [] }

        var uninstalls = [String]()
        var graph = _formulaes
        var set = Set<String>()
        set.insert(formulae)

        while let current = set.popFirst() {
            let incomings = graph.incomings(for: current)!
            let data = graph.data(for: current)!

            guard incomings.isEmpty else { continue }

            if (data.isProtected && current == formulae) || !data.isProtected {
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
        guard _formulaes.contains(formulae) else { return }
        
        let data = _formulaes.data(for: formulae)!

        for label in data.labels {
            dataBase?.removeLabel(label, from: formulae)
        }

        dataBase?.removeFormulae(formulae)
        dataBase?.write()

        try self.brew.uninstallFormulae(formulae)
    }

    // MARK: List

    public func formulaes() -> [String] {
        var list = [String]()

        for formulae in _formulaes {
            list.append(formulae.node)
        }

        return list
    }

    public func formulaes(under label: String) -> Set<String> {
        return self.dataBase?.formulaes(under: label) ?? Set<String>()
    }

    // MARK: Label

    public func removeLabel(_ label: String) throws {
        self.dataBase?.removeLabel(label)
        self.dataBase?.write()
    }

    public func labelFormulae(
        _ formulae: String,
        as label: String) throws {
        guard let dataBase = self.dataBase else { return }

        if !dataBase.hasLabel(label) {
            dataBase.createLabel(label)
        }
        
        self.dataBase?.addLabel(label, to: formulae)
        self.dataBase?.write()
    }

    public func removeLabel(_ label: String, from formulae: String) throws {
        self.dataBase?.removeLabel(label, from: formulae)
        self.dataBase?.write()
    }
}
