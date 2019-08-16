//
//  BrewExtensionRemoveLabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionRemoveLabel: Executor {
    func run(with context: ASTContext) {
        let label = context.unnamedParams[0] as! String
        let cache = EncodableCache.load(with: context)

        cache.removeLabel(label)

        cache.save(with: context)
    }
}
