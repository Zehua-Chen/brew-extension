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
    public var brew: Brew
    public var uninstalls = [String]()

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.brew = Brew(url: url)
    }

    /// Fetch formulae info from homebrew
    ///
    /// - Throws:
    public func fetch() throws {
        let list = try self.brew.list()
        let rawInfos = try self.brew.info(of: list)

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
    }

    /// Sync the information of the brew extension into a database
    ///
    /// - Parameter db: the data base to write into
    public func sync<DB: DataBase>(into db: inout DB) {
        db.saveFormulaes(self.formulaes)
    }

    public func install(formulae: String) {

    }

    public func uninstall(formulae: String) {

//        guard self.formulaes.contains(formulae) else { return }
//
//        var graph = self.formulaes
//        var stack = Set<String>()
//        stack.insert(formulae)
//
//        while !stack.isEmpty {
//            let current = stack.popFirst()!
//            let incomings = graph.incomings(at: current)!
//
//            if incomings.count == 0 {
//                let outcomings = graph.outcomings(at: current)!
//
//                for outcoming in outcomings {
//                    if !stack.contains(outcoming) {
//                        stack.insert(outcoming)
//                    }
//                }
//
//                self.formulaes[current]!.action = .uninstall
//                graph.remove(current)
//                uninstalls.append(current)
//            }
//        }
    }

    public func commit() throws {
//        for item in self.formulaes {
//            switch item.data.action {
//            case .nothing:
//                continue
//            case .uninstall:
//                try brew.uninstall(formulae: item.node)
//            }
//        }
    }
}
