//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import BrewExtension
import Foundation

print("loading data")
let app = BrewExtension()
try! app.sync()

print(app.formulaes.incomings(at: "readline")!)
