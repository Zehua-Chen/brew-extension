//
//  BrewExtensionUnlabel.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionUnlabel: Executor {
    func run(with context: ASTContext) {
        let formulae = context.unnamedParams[0] as! String
        let label = context.unnamedParams[1] as! String
        let cache = EncodableDataSource.load(with: context)

        guard cache.containsLabel(label) else { return }
        guard cache.containsFormulae(formulae) else { return }

        cache.removeLabel(label, from: formulae)
        cache.save(with: context)
    }
}
