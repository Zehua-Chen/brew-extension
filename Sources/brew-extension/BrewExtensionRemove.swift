//
//  BrewExtensionRemove.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionRemove: Command, FindUninstallablesOperation, UninstallOperation {

    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Option(name: "--yes", defaultValue: false))
        config.use(Parameter(type: String.self))
        config.use(BrewExtensionRemoveLabel(), for: "label")
        config.use(BrewExtensionRemoveCache(), for: "cache")
    }

    func run(with context: CommandContext) {
        var cache = EncodableDataSource.load(with: context)
        let formulaeToUninstall = context.parameters[0] as! String

        let uninstalls = self.findUninstallableFormulaes(for: formulaeToUninstall, using: cache)

        print("the following packages will be uninstalled")

        for uninstall in uninstalls {
            print(uninstall)
        }

        var yes = context.options["--yes"] as! Bool

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
