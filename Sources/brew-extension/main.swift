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

var app = CommandLineApplication(name: "brew-extension")
let defaultdDataPath = "\(NSHomeDirectory())/.brew-extension"
let brewExt = BrewExtension()

// MARK: brew-extension sync

let sync = try! app.addPath(["brew-extension", "sync"]) { (context) in
    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    try! brewExt.sync()
}

sync.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension list

let list = try! app.addPath(["brew-extension", "list"]) { (context) in
    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    if let label = context.namedParams["--label"] as? String {
        for formulae in brewExt.formulaes(under: label) {
            print(formulae)
        }

        return
    }

    for formulae in brewExt.formulaes() {
        print(formulae)
    }
}

list.registerNamedParam("--path", defaultValue: defaultdDataPath)
list.registerNamedParam("--label", type: String.self)

// MARK: brew-extension label

let label = try! app.addPath(["brew-extension", "label"]) { (context) in
    let formulae = context.unnamedParams[0] as! String
    let label = context.unnamedParams[1] as! String

    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    try! brewExt.labelFormulae(formulae, as: label)
}

label.addUnnamedParam(String.self)
label.addUnnamedParam(String.self)

label.registerNamedParam("--path", defaultValue: defaultdDataPath)

let unlabel = try! app.addPath(["brew-extension", "unlabel"]) { (context) in
    let formulae = context.unnamedParams[0] as! String
    let label = context.unnamedParams[1] as! String

    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    try! brewExt.removeLabel(formulae, from: label)
}

unlabel.addUnnamedParam(String.self)
unlabel.addUnnamedParam(String.self)
unlabel.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove label

let removeLabel = try! app.addPath(["brew-extension", "remove", "label"]) { (context) in
    let label = context.unnamedParams[0] as! String

    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    try! brewExt.removeLabel(label)
}

removeLabel.addUnnamedParam(String.self)
removeLabel.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove cache

let removeCache = try! app.addPath(["brew-extension", "remove", "cache"]) { (context) in
    let dataPath = context.namedParams["--path"] as! String
    let dataBase = JsonDataBase.createOrLoad(from: dataPath)

    try! dataBase.remove()
}

removeCache.addUnnamedParam(String.self)
removeCache.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove formulae

let removeFormulae = try! app.addPath(["brew-extension", "remove", "formulae"]) { (context) in
    let dataPath = context.namedParams["--path"] as! String
    let formulaeToUninstall = context.unnamedParams[0] as! String

    let dataBase = JsonDataBase.createOrLoad(from: dataPath)
    brewExt.dataBase = dataBase

    let uninstalls = brewExt.findFormulaesToUninstall(for: formulaeToUninstall)

    print("the following packages will be uninstalled")

    for uninstall in uninstalls {
        print(uninstall)
    }

    var yes = context.namedParams["--yes"] as! Bool

    if !yes {
        yes = Input<Bool>.read(prompt: "remove? (y/f)", defaultValue: false)
    }

    if yes {
        for uninstall in uninstalls {
            try! brewExt.uninstallFormulae(uninstall)
        }
    }
}

removeFormulae.registerNamedParam("--yes", defaultValue: false)
removeFormulae.registerNamedParam("--path", defaultValue: defaultdDataPath)
removeFormulae.addUnnamedParam(String.self)

do {
    try app.run()
} catch {
    print(error)
}
