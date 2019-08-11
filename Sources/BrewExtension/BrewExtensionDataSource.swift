//
//  DataBase.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/22/19.
//

public protocol BrewExtensionDataSource: AnyObject {
    
    // MARK: Formulaes

    /// Save formulaes
    ///
    /// - Parameter formulaes: the formulaes to save
    /// - Throws:
    func saveFormulaes(_ formulaes: BrewExtension.Formulaes) throws

    /// Load formulaes
    ///
    /// - Returns: loaded formulaes, if no existing info exist, returns empty
    /// graph
    /// - Throws:
    func loadFormulaes() throws -> BrewExtension.Formulaes

    func removeFormulae(_ formulae: String) throws

    // MARK: Labels

    func removeLabel(_ label: String) throws
    func labelFormulae(_ formulae: String, as labels: String) throws
    func saveLabels(_ labels: BrewExtension.Labels) throws
    func loadLabels() throws -> BrewExtension.Labels
}
