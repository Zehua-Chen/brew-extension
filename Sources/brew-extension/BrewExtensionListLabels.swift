//
//  BrewExtensionListLables.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionListLabels: Command {
    func setup(with config: Configuration) {
        config.usePathOption()
    }
    
    func run(with context: CommandContext) {
        let cache = EncodableDataSource.load(with: context)
        let labels = cache.labels()

        for label in labels {
            print(label)
        }
    }
}
