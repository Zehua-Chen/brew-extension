//
//  BrewExtensionLabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionLabel: Command {

    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Parameter(type: String.self))
        config.use(Parameter(type: String.self))
    }
    
    func run(with context: CommandContext) {
        let formulae = context.parameters[0] as! String
        let label = context.parameters[1] as! String
        let cache = EncodableDataSource.load(with: context)

        if !cache.containsLabel(label) {
            cache.addLabel(label)
        }

        cache.addLabel(label, to: formulae)

        cache.save(with: context)
    }
}
