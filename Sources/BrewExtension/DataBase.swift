//
//  DataBase.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/22/19.
//

public protocol DataBase {
    // MARK: Write

    /// Save formulaes
    ///
    /// - Parameter formulaes: the formulaes to save
    /// - Throws:
    mutating func saveFormulaes(_ formulaes: Graph<String, FormulaeInfo>) throws

    // MARK: Read

    /// Load formulaes
    ///
    /// - Returns: loaded formulaes, if no existing info exist, returns empty
    /// graph
    /// - Throws: 
    func loadFormulaes() throws -> Graph<String, FormulaeInfo>
}
