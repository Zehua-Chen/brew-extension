//
//  main.swift
//  brew-extension
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import BrewExtension
import SwiftArgParse
import Foundation

struct BrewExtension: Command {
    func setup(with config: Configuration) {
        config.use(BrewExtensionSync(), for: "sync")
        config.use(BrewExtensionList(), for: "list")
        config.use(BrewExtensionLabel(), for: "label")
        config.use(BrewExtensionRemove(), for: "remove")
        config.use(BrewExtensionProtect(), for: "protect")
        config.use(BrewExtensionUnprotect(), for: "unprotect")
    }

    func run(with context: CommandContext) {
    }
}

CommandLine.run(BrewExtension())
