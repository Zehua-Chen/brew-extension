//
//  BrewExtensionUnlabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionUnlabel: Command {

    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Parameter(type: String.self))
        config.use(Parameter(type: String.self))
    }
    
    func run(with context: CommandContext) {
        let formulae = context.parameters[0] as! String
        let label = context.parameters[1] as! String
        let cache = EncodableDataSource.load(with: context)

        guard cache.containsLabel(label) else { return }
        guard cache.containsFormulae(formulae) else { return }

        cache.removeLabel(label, from: formulae)
        cache.save(with: context)
    }
}
