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
import Logging

var app = CommandLineApplication(name: "brew-extension")
let dataPath = "\(NSHomeDirectory())/.brew-extension"

// MARK: brew-extension sync

let sync = try! app.addPath(["brew-extension", "sync"]) { (context) in
    let brewExt = BrewExtension()
    let logger = Logger(label: "brew-extension")
    let dataPath = context.namedParams["--path"] as! String

    logger.info("connecting to database")

    var db = JsonDataBase.createOrLoad(from: dataPath)
    logger.notice("database at \(dataPath)")

    do {
        logger.info("fetching data from homebrew")
        try brewExt.sync(into: &db)
        logger.info("saving to database")
    } catch {
        print(error)
    }
}

sync.registerNamedParam("--path", defaultValue: dataPath)

// MARK: brew-extension uninstall

let uninstall = try! app.addPath(["brew-extension", "uninstall"]) { (context) in
    let brewExt = BrewExtension()
    let logger = Logger(label: "brew-extension")
    let dataPath = context.namedParams["--path"] as! String

    logger.info("connecting to database")

    let db = JsonDataBase.createOrLoad(from: dataPath)
    logger.notice("database at \(dataPath)")

    try! brewExt.load(from: db)
    brewExt.uninstallFormulae(context.unnamedParams[0] as! String)

    let uninstalls = brewExt.uninstalls

    logger.critical("packages to be uninstalled \(uninstalls)")

    var yes = context.namedParams["-y"] as! Bool

    if !yes {
        yes = Input<Bool>.read(prompt: "uninstall? (y/f)", defaultValue: false)
    }

    if yes {
        for uninstall in uninstalls {
            logger.info("uninstalling \(uninstall)")
            try! brewExt.brew.uninstall(formulae: uninstall)
        }
    }
}

uninstall.registerNamedParam("-y", defaultValue: false)
uninstall.registerNamedParam("--path", defaultValue: dataPath)
uninstall.addUnnamedParam(String.self)

do {
    try app.run()
} catch {
    print(error)
}
