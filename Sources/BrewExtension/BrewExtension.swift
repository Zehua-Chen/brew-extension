//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import Foundation

public final class BrewExtension {

    /// The brew object used to get information from homebrew
    public internal(set) var brew: Brew

    /// A graph kept in sync with the information from the database.
    /// The BrewExtension instance keeps a separate graph so that graph
    /// duplications in Graph algorithms are faster
    public internal(set) var formulaeGraph = Graph<String, FormulaeInfo>()

    /// The data base. The BrewExtension use it to sync data with a permanent
    /// storage
    public weak var dataBase: BrewExtensionDataBase? {
        didSet {
            guard let db = self.dataBase else { return }

            self.formulaeGraph = .init()

            let formulaes = db.formulaes()

            for formulae in formulaes {
                let protected = db.protectsFormulae(formulae)
                let labels = db.labels(of: formulae)
                self.formulaeGraph.insert(formulae, with: .init(
                    isProtected: protected,
                    labels: labels))
            }

            for formulae in formulaes {
                let outcomings = db.outcomingDependencies(for: formulae)

                for outcoming in outcomings {
                    self.formulaeGraph.connect(from: formulae, to: outcoming)
                }
            }
        }
    }

    /// Create a brew extension from a given URL
    ///
    /// - Parameter url: the url used to initialize the Homebrew encapsulation
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

        self.formulaeGraph = .init()

        for info in rawInfos {
            // TODO: init formulae info
            self.formulaeGraph.insert(info.name, with: FormulaeInfo())

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
                if self.formulaeGraph.contains(dep) {
                    self.formulaeGraph.connect(from: name, to: dep)
                }

                if let dataBase = self.dataBase {
                    if dataBase.containsFormulae(dep) && !dataBase.hasDependency(from: name, to: dep) {
                        dataBase.addDependency(from: name, to: dep)
                    }
                }
            }
        }

        // Merge formulae infos

        for formulae in self.formulaeGraph {
            let protected = self.dataBase?.protectsFormulae(formulae.node) ?? false
            let labels = self.dataBase?.labels(of: formulae.node) ?? Set<String>()

            self.formulaeGraph[formulae.node] = .init(
                isProtected: protected,
                labels: labels)
        }

        self.dataBase?.write()
    }

    // MARK: Uninstall

    /// Find formulaes that can be uninstalled when a given formulae can be
    /// uninstalled
    ///
    /// - Parameter formulae: the formulae to uninstall
    /// - Returns: a list of uninstallable formulaes
    public func findFormulaesToUninstall(for formulae: String) -> [String] {
        guard self.formulaeGraph.contains(formulae) else { return [] }

        var uninstalls = [String]()
        var graph = self.formulaeGraph
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

    /// Uninstall a formulae
    ///
    /// This method only uninstall a one single formulae, to find other
    /// formulaes that can be uninstalled,
    /// use `findFormulaesToUninstall(for:)`
    /// - Parameter formulae: the formulae to uninstall
    /// - Throws:
    public func uninstallFormulae(_ formulae: String) throws {
        guard self.formulaeGraph.contains(formulae) else { return }
        
        let data = self.formulaeGraph.data(for: formulae)!

        for label in data.labels {
            dataBase?.removeLabel(label, from: formulae)
        }

        dataBase?.removeFormulae(formulae)
        dataBase?.write()

        try self.brew.uninstallFormulae(formulae)
    }

    // MARK: List

    /// Get an array of formulaes
    ///
    /// - Returns: an array of formulaes
    public func formulaes() -> [String] {
        var list = [String]()

        for formulae in self.formulaeGraph {
            list.append(formulae.node)
        }

        return list
    }

    /// Get a set of formulaes under a label
    ///
    /// - Parameter label: the label to lookup formulaes with
    /// - Returns: a set of formulaes under a label
    public func formulaes(under label: String) -> Set<String> {
        return self.dataBase?.formulaes(under: label) ?? Set<String>()
    }

    public func labels() -> [String] {
        return self.dataBase?.labels() ?? []
    }

    // MARK: Label

    /// Label a formulae
    ///
    /// - Parameters:
    ///   - formulae: the formulae to label
    ///   - label: the label used
    /// - Throws:
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

    /// Remove a label
    ///
    /// Once a label is removed, no formulaes will have this label
    /// - Parameter label: the label to remove
    /// - Throws:
    public func removeLabel(_ label: String) throws {
        self.dataBase?.removeLabel(label)
        self.dataBase?.write()
    }

    /// Remove a label from a formulae
    ///
    /// - Parameters:
    ///   - label: the label to remove
    ///   - formulae: a formulae where the label is removed
    /// - Throws: 
    public func removeLabel(_ label: String, from formulae: String) throws {
        self.dataBase?.removeLabel(label, from: formulae)
        self.dataBase?.write()
    }
}
