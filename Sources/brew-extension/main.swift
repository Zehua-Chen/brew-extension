//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import BrewExtension
import Brew

print(try! Brew.list())
print(try! Brew.deps(for: "llvm"))
