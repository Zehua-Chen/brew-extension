//
//  BrewExtensionListLables.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import BrewExtension

struct BrewExtensionListLabels: Executor {
    func run(with context: ASTContext) {
        let cache = EncodableCache.load(with: context)
        let labels = cache.labels().map { return $0.name }

        for label in labels {
            print(label)
        }
    }
}
