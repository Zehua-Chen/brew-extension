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

// MARK: brew-extension sync

let sync = try! app.addPath(["brew-extension", "sync"], executor: BrewExtensionSync())

sync.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension list

let list = try! app.addPath(["brew-extension", "list"], executor: BrewExtensionList())

list.registerNamedParam("--path", defaultValue: defaultdDataPath)
list.registerNamedParam("--label", type: String.self)
list.registerNamedParam("--protected", defaultValue: false)

// MARK: brew-extension list labels

let listLabels = try! app.addPath(["brew-extension", "list", "labels"], executor: BrewExtensionListLabels())

listLabels.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension label

let label = try! app.addPath(["brew-extension", "label"], executor: BrewExtensionLabel())

label.addUnnamedParam(String.self)
label.addUnnamedParam(String.self)

label.registerNamedParam("--path", defaultValue: defaultdDataPath)

let unlabel = try! app.addPath(
    ["brew-extension", "unlabel"],
    executor: BrewExtensionUnlabel())

unlabel.addUnnamedParam(String.self)
unlabel.addUnnamedParam(String.self)
unlabel.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove label

let removeLabel = try! app.addPath(["brew-extension", "remove", "label"], executor: BrewExtensionRemoveLabel())

removeLabel.addUnnamedParam(String.self)
removeLabel.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove cache

let removeCache = try! app.addPath(["brew-extension", "remove", "cache"]) { (context) in
    let dataPath = context.namedParams["--path"] as! String
    let manager = FileManager.default

    try! manager.removeItem(atPath: dataPath)
}

removeCache.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension remove

let removeFormulae = try! app.addPath(["brew-extension", "remove"], executor: BrewExtensionRemove())

removeFormulae.registerNamedParam("--yes", defaultValue: false)
removeFormulae.registerNamedParam("--path", defaultValue: defaultdDataPath)
removeFormulae.addUnnamedParam(String.self)

// MARK: brew-extension protect

let protect = try! app.addPath(["brew-extension", "protect"], executor: BrewExtensionProtect())

protect.addUnnamedParam(String.self)
protect.registerNamedParam("--path", defaultValue: defaultdDataPath)

// MARK: brew-extension unprotect

let unprotect = try! app.addPath(["brew-extension", "unprotect"], executor: BrewExtensionUnprotect())

unprotect.addUnnamedParam(String.self)
unprotect.registerNamedParam("--path", defaultValue: defaultdDataPath)

do {
    try app.run()
} catch {
    print(error)
}
