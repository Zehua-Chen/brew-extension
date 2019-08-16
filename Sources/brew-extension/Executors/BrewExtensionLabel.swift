//
//  BrewExtensionLabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionLabel: Executor {
    func run(with context: ASTContext) {
        let formulae = context.unnamedParams[0] as! String
        let label = context.unnamedParams[1] as! String
        let cache = EncodableCache.load(with: context)

        if !cache.containsLabel(label) {
            cache.addLabel(label)
        }

        cache.addLabel(label, to: formulae)

        cache.save(with: context)
    }
}
