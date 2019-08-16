//
//  BrewExtensionList.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

import BrewExtension
import SwiftArgParse

struct BrewExtensionList: Executor {
    func run(with context: ASTContext) {
        let cache = EncodableCache.load(with: context)
        var formulaes = cache.formulaes().map { return $0.name }

        if context.namedParams["--protected"] as! Bool {
            formulaes = formulaes.filter {
                return cache.protectsFormulae($0)
            }
        }

        if let label = context.namedParams["--label"] as? String {
            formulaes = formulaes.filter {
                return cache.labels(of: $0).contains(where: { return $0.name == label })
            }
        }

        for formulae in formulaes {
            print(formulae)
        }
    }
}
