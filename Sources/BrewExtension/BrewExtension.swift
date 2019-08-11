//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import Foundation

public final class BrewExtension {

    public internal(set) var formulaes = Graph<String, FormulaeInfo>()
    public internal(set) var brew: Brew

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.brew = Brew(url: url)
    }

    /// Sync formulae info with homebrew
    ///
    /// - Throws:
    public func sync<DB: DataBase>(into db: inout DB) throws {
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

        let existingFormulaes = try db.loadFormulaes()

        for existingFormulae in existingFormulaes {
            self.formulaes[existingFormulae.node] = existingFormulae.data
        }

        try db.saveFormulaes(self.formulaes)
    }

    /// Sync the information of the brew extension into a database
    ///
    /// - Parameter db: the data base to write into
    public func flush<DB: DataBase>(into db: inout DB) throws {
        try db.saveFormulaes(self.formulaes)
    }

    public func load<DB: DataBase>(from db: DB) throws {
        self.formulaes = try db.loadFormulaes()
    }

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
}
