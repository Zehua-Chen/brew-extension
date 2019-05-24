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
    public internal(set) var changedFormulaes = Set<String>()

    public var brew: Brew

    public var uninstalled: Set<String> {
        var temp = Set<String>()

        for node in self.formulaes {
            if node.data?.action == .uninstall {
                temp.insert(node.node)
            }
        }

        return temp
    }

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.brew = Brew(url: url)
    }

    public func sync() throws {
        let list = try self.brew.list()
        let infos = try self.brew.info(for: list)

        for info in infos {
            self.formulaes.add(node: info.name, with: FormulaeInfo())
        }

        for info in infos {
            let name = info.name

            for dep in info.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if self.formulaes.contains(node: dep) {
                    self.formulaes.connect(from: name, to: dep)
                }
            }
        }
    }

    public func install(formulae: String) {

    }

    public func uninstall(formulae: String) {

        guard self.formulaes.contains(node: formulae) else { return }

        var graph = self.formulaes
        var stack = Set<String>()
        stack.insert(formulae)

        while !stack.isEmpty {
            let current = stack.popFirst()!
            let incomings = graph.incomings(at: current)!

            if incomings.count == 0 {
                let outcomings = graph.outcomings(at: current)!

                for outcoming in outcomings {
                    if !stack.contains(outcoming) {
                        stack.insert(outcoming)
                    }
                }

                self.formulaes[current]!.action = .uninstall
                graph.remove(node: current)
            }
        }
    }

    public func commit() {

    }

    public func cache<DB: DataBase>(to db: inout DB) {
    }

    public func load<DB: DataBase>(from db: DB) {
    }
}
