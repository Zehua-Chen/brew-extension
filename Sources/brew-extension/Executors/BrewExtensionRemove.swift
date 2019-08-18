//
//  BrewExtensionRemove.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionRemove: Executor, FindUninstallablesOperation, UninstallOperation {

    func run(with context: ASTContext) {
        var cache = EncodableCache.load(with: context)
        let formulaeToUninstall = context.unnamedParams[0] as! String

        let uninstalls = self.findUninstallableFormulaes(for: formulaeToUninstall, using: cache)

        print("the following packages will be uninstalled")

        for uninstall in uninstalls {
            print(uninstall)
        }

        var yes = context.namedParams["--yes"] as! Bool

        if !yes {
            yes = Input<Bool>.read(prompt: "remove? (y/f)", defaultValue: false)
        }

        if yes {
            for uninstall in uninstalls {
                try! self.uninstallFormulae(uninstall, with: .init(), using: &cache)
            }
        }

        cache.save(with: context)
    }
}
