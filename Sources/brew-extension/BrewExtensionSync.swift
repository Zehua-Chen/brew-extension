//
//  BrewExtensionSync.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

import Foundation
import BrewExtension
import SwiftArgParse

struct BrewExtensionSync: SyncOperation, Command {

    func setup(with config: Configuration) {
        config.usePathOption()
    }
    
    func run(with context: CommandContext) {
        var cache = EncodableDataSource.load(with: context)
        try! self.sync(into: &cache, brew: .init())

        cache.save(with: context)
    }
}
