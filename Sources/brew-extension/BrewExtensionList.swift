//
//  BrewExtensionList.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

import BrewExtension
import SwiftArgParse

struct BrewExtensionList: Command {

    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Option(name: "--label", defaultValue: ""))
        config.use(Option(name: "--protected", defaultValue: false))
        config.use(BrewExtensionListLabels(), for: "labels")
    }
    
    func run(with context: CommandContext) {
        let cache = EncodableDataSource.load(with: context)
        var formulaes = cache.formulaes()

        if context.options["--protected"] as! Bool {
            formulaes = formulaes.filter {
                return cache.protectsFormulae($0)
            }
        }

        if let label = context.options["--label"] as? String {
            formulaes = formulaes.filter {
                return cache.labels(of: $0).contains(label)
            }
        }

        for formulae in formulaes {
            print(formulae)
        }
    }
}
