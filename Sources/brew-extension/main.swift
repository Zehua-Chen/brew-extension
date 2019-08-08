//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import BrewExtension
import SwiftArgParse
import Foundation
import Logging

var app = CommandLineApplication(name: "brew-extension")

let sync = try! app.addPath(["brew-extension", "sync"]) { (context) in
    let brewExt = BrewExtension()
    let logger = Logger(label: "brew-extension")
    let dataPath = context.namedParams["--path"] as! String

    logger.info("connecting to database")

    var db = JsonDataBase.makeDefault(path: dataPath)
    logger.notice("database at \(dataPath)")

    do {
        logger.info("fetching data from homebrew")
        try brewExt.fetch()
    } catch {
        print(error)
    }

    logger.info("saving to database")
    brewExt.sync(into: &db)
}

sync.registerNamedParam("--path", defaultValue: "\(NSHomeDirectory())/.brew-extension")

let uninstall = try! app.addPath(["brew-extension", "uninstall"]) { (context) in
}

uninstall.registerNamedParam("-y", defaultValue: false)
uninstall.addUnnamedParam(String.self)

do {
    try app.run()
} catch {
    print(error)
}
