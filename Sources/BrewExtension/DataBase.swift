//
//  DataBase.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/22/19.
//

public protocol DataBase {
    mutating func saveFormulaes(_ formulaes: Graph<String, FormulaeInfo>)
}
