//
//  File.swift
//  
//
//  Created by Zehua Chen on 11/28/19.
//

import Foundation
import SwiftArgParse

struct BrewExtensionRemoveCache: Command {
    func setup(with config: Configuration) {
        config.usePathOption()
    }

    func run(with context: CommandContext) {
        let dataPath = context.options["--path"] as! String
        let manager = FileManager.default

        try! manager.removeItem(atPath: dataPath)
    }
}
