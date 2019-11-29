//
//  BrewExtensionRemoveLabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionRemoveLabel: Command {
    func setup(with config: Configuration) {
        config.usePathOption()
        config.use(Parameter(type: String.self))
    }
    func run(with context: CommandContext) {
        let label = context.parameters[0] as! String
        let cache = EncodableDataSource.load(with: context)

        cache.removeLabel(label)

        cache.save(with: context)
    }
}
