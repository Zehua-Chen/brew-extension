//
//  BrewExtension.swift
//  Brew
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import Foundation

public final class BrewExtension {

    public var formulaes = Graph<String>()
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
}
