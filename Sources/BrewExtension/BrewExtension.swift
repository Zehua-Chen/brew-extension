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
        let formulaes = try self.brew.list()

        for formulae in formulaes {
            self.formulaes.add(node: formulae)
        }

        for formulae in formulaes {
            let deps = try self.brew.deps(for: formulae)

            for dep in deps {
                self.formulaes.connect(from: formulae, to: dep)
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
            let inbounds = self.formulaes.inbound(at: current)!

            if inbounds.count == 0 {
                uninstalls.append(current)
                let outbounds = self.formulaes.outbound(at: current)!

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

    public func rawUninstall(items: [String]? = nil) {

    }

    public func cache<DB: DataBase>(to db: inout DB) {
    }

    public func load<DB: DataBase>(from db: DB) {
    }
}
