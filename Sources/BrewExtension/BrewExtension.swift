//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import Foundation

public final class BrewExtension {

    public internal(set) var formulaes = Graph<String>()

    public var brew: Brew

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.brew = Brew(url: url)
    }

    public func sync() throws {
        let list = try self.brew.list()
        let infos = try self.brew.info(for: list)

        for info in infos {
            self.formulaes.add(node: info.name)
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

    public func itemsToBeUninstalled(for formulae: String) -> [String] {

        guard self.formulaes.contains(node: formulae) else {
            return []
        }

        var uninstalls = [String]()
        var stack = Set<String>()
        stack.insert(formulae)

        while !stack.isEmpty {
            let current = stack.popFirst()!
            let inbounds = self.formulaes.incomings(at: current)!

            if inbounds.count == 0 {
                uninstalls.append(current)
                let outbounds = self.formulaes.outcomings(at: current)!

                for outbound in outbounds {
                    if !stack.contains(outbound) {
                        stack.insert(outbound)
                    }
                }

                self.formulaes.remove(node: current)
            }
        }

        return uninstalls
    }

    public func uninstall(formulae: String) {

    }

    public func cache<DB: DataBase>(to db: inout DB) {
    }

    public func load<DB: DataBase>(from db: DB) {
    }
}
