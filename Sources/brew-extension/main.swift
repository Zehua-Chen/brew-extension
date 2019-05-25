//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Brew
import BrewExtension
import Foundation

let app = BrewExtension()
try! app.sync()
app.uninstall(formulae: "ghostscript")
print(app.uninstalls)
//try! app.commit()
