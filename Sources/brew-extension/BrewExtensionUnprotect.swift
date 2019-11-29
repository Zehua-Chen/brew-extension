//
//  BrewExtensionUnprotect.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionUnprotect: Command {
    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Parameter(type: String.self))
    }

    func run(with context: CommandContext) {
        let cache = EncodableDataSource.load(with: context)
        let formulae = context.parameters[0] as! String

        guard cache.containsFormulae(formulae) else { return }

        cache.unprotectFormulae(formulae)
        cache.save(with: context)
    }
}
