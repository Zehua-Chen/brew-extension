//
//  BrewExtensionUnprotect.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionUnprotect: Executor {
    func run(with context: ASTContext) {
        let cache = EncodableDataSource.load(with: context)
        let formulae = context.unnamedParams[0] as! String

        guard cache.containsFormulae(formulae) else { return }

        cache.unprotectFormulae(formulae)
        cache.save(with: context)
    }
}
