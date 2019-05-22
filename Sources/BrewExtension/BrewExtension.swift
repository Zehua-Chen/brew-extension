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

        guard let outbounds = self.formulaes.outbound(at: formulae) else {
            return []
        }

        var uninstalls = [String]()
        uninstalls.append(formulae)
        
        for outbound in outbounds {
            let outboundDependents = self.formulaes.inbound(at: outbound)!
            if outboundDependents.contains(formulae) && outboundDependents.count == 1 {
                uninstalls.append(outbound)
            }
        }

        return uninstalls
    }

    public func uninstall(formulae: String, hints: [String]? = nil) {

    }

    public func save<DB: DataBase>(to db: inout DB) {
    }

    public func load<DB: DataBase>(from db: DB) {
    }
}
