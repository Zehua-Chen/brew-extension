//
//  BrewExtensionSync.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

import Foundation
import BrewExtension
import SwiftArgParse

struct BrewExtensionSync: SyncOperation, Executor {
    func run(with context: ASTContext) {
        var cache = EncodableCache.load(with: context)
        try! self.sync(into: &cache, brew: .init())

        cache.save(with: context)
    }
}
