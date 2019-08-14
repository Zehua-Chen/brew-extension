//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

import Foundation

public final class BrewExtension {

    /// The brew object used to get information from homebrew
    public internal(set) var brew: Brew

    /// The data base. The BrewExtension use it to sync data with a permanent
    /// storage
    public weak var dataBase: BrewExtensionDataBase?

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

        guard let db = self.dataBase else { return }

        if providedRawInfos != nil {
            rawInfos = providedRawInfos!
        } else {
            rawInfos = try self.brew.info(of: list)
        }

        for rawInfo in rawInfos {
            // TODO: init formulae info
            if !db.containsFormulae(rawInfo.name) {
                db.addFormulae(rawInfo.name)
            }
        }

        // build connections

        for rawInfo in rawInfos {
            let name = rawInfo.name

            for dep in rawInfo.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if db.containsFormulae(dep) && !db.containsDependency(from: name, to: dep) {
                    db.addDependency(from: name, to: dep)
                }
            }
        }

        // Merge formulae infos

        db.write()
    }

    // MARK: Uninstall

    /// Find formulaes that can be uninstalled when a given formulae can be
    /// uninstalled
    ///
    /// - Parameter formulae: the formulae to uninstall
    /// - Returns: a list of uninstallable formulaes
    public func findFormulaesToUninstall(for formulae: String) -> [String] {
        guard let db = self.dataBase else { return [] }
        guard db.containsFormulae(formulae) else { return [] }

        var uninstalls = [String]()
        var graph = Graph<String, FormulaeInfo>()
        db.initializeGraph(&graph)

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
        guard let db = self.dataBase else { return }
        guard db.containsFormulae(formulae) else { return }

        for label in db.labels(of: formulae) {
            db.removeLabel(label, from: formulae)
        }

        db.removeFormulae(formulae)
        db.write()

        try self.brew.uninstallFormulae(formulae)
    }

    public func protectFormulae(_ formulae: String) {
        guard let db = self.dataBase else { return }
        guard db.containsFormulae(formulae) else { return }

        db.protectFormulae(formulae)
        db.write()
    }

    public func unprotectFormulae(_ formulae: String) {
        guard let db = self.dataBase else { return }
        guard db.containsFormulae(formulae) else { return }

        db.unprotectFormulae(formulae)
        db.write()
    }

    // MARK: List

    /// Get an array of formulaes
    ///
    /// - Returns: an array of formulaes
    public func formulaes() -> [String] {
        guard let db = self.dataBase else { return [] }
        return db.formulaes()
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

    /// Add a label
    ///
    /// - Parameter label: <#label description#>
    public func addLabel(_ label: String) {
        guard let dataBase = self.dataBase else { return }
        guard !dataBase.containsLabel(label) else { return }

        dataBase.addLabel(label)
    }

    /// Label a formulae
    ///
    /// - Parameters:
    ///   - formulae: the formulae to label
    ///   - label: the label used, if the label does not exist, a label
    ///   will be created
    /// - Throws:
    public func labelFormulae(
        _ formulae: String,
        as label: String) throws {
        guard let dataBase = self.dataBase else { return }

        if !dataBase.containsLabel(label) {
            dataBase.addLabel(label)
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
