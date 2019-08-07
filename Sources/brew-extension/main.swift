//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import BrewExtension
import SwiftArgParse

let brewExt = BrewExtension()
var app = CommandLineApplication(name: "brew-extension")

let sync = try! app.addPath(["brew-extension", "sync"]) { (context) in
    try! brewExt.sync()
}

let uninstall = try! app.addPath(["brew-extension", "uninstall"]) { (context) in
}

uninstall.registerNamedParam("-y", defaultValue: false)
uninstall.addUnnamedParam(String.self)

do {
    try app.run()
} catch {
    print(error)
}
