//
//  DataBase.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/22/19.
//

public protocol BrewExtensionDataSource: AnyObject {
    
    // MARK: Formulaes
    var formulaes: BrewExtension.Formulaes { get set }
    var labels: BrewExtension.Labels { get set }

    func flush() throws
    func load() throws
}
