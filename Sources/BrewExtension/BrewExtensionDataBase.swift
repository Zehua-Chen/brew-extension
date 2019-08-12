//
//  DataBase.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/22/19.
//

/// Data source of an instance of a `BrewExtension`
public protocol BrewExtensionDataBase: AnyObject {

    // MARK: Label

    /// Get labels of a formulae
    ///
    /// - Parameter formulae: the formlae to look up label for
    /// - Returns: name of the labels
    func labels(of formulae: String) -> Set<String>

    /// Get an array of labels
    ///
    /// - Returns: get an array of labels
    func labels() -> [String]

    /// Get formulaes under a label
    ///
    /// - Parameter label: the name of the label
    /// - Returns: a set of the names of the formulaes under the label
    func formulaes(under label: String) -> Set<String>

    /// Remove a label from a formulae
    ///
    /// - Parameters:
    ///   - label: the name of the label to remove
    ///   - formulae: the name fo the formulae to remove name from
    func removeLabel(_ label: String, from formulae: String)

    /// Add a label to a formulae
    ///
    /// - Parameters:
    ///   - label: the label to add to a formulae
    ///   - formulae: the formulae where the label is added
    func addLabel(_ label: String, to formulae: String)

    /// Create a label
    ///
    /// - Parameter label: the name of the label
    func createLabel(_ label: String)

    /// Remove a label
    ///
    /// The label should be removed from all the formulaes with this label
    /// - Parameter label: the label to remove
    func removeLabel(_ label: String)

    func hasLabel(_ label: String) -> Bool

    // MARK: Protected Formulaes

    /// Protect a formulae from uninstallation
    ///
    /// - Parameter formulae: the formulae to protect
    func protectFormulae(_ formulae: String)

    /// Determine if the formulae is protected
    ///
    /// - Parameter formulae: the formulae to lookup protection status for
    /// - Returns: true if protected, false otherwise
    func protectsFormulae(_ formulae: String) -> Bool

    /// Unprotect a formulae
    ///
    /// - Parameter formulae: the formulae to unprotect
    func unprotectFormulae(_ formulae: String)

    // MARK: Formulaes

    /// Determine if a formulae is present in the data source
    ///
    /// - Parameter formulae: the formulae to look up
    /// - Returns: true if the formulae is present in the data source
    func containsFormulae(_ formulae: String) -> Bool

    /// Add a formulae
    ///
    /// - Parameter formulae: the name of the formulae to add
    func addFormulae(_ formulae: String)

    /// Remove a formulae
    ///
    /// When a formulae is removed, all its dependencies should also be removed
    /// - Parameter formulae: the formulae to remove
    func removeFormulae(_ formulae: String)

    /// Get an array of formulaes (formulae names)
    ///
    /// - Returns: an array of formulaes
    func formulaes() -> [String]

    // MARK: Formulae Dependencies


    /// Add a dependency from a given node to a given node
    ///
    /// - Parameters:
    ///   - from: the source node
    ///   - to: the destinatino node
    func addDependency(from: String, to: String)

    /// Determine if a dependency exists
    ///
    /// - Parameters:
    ///   - from: the source formulae
    ///   - to: the destination formulae
    func hasDependency(from: String, to: String) -> Bool

    /// Get outcoming dependencies for a formulae
    ///
    /// - Parameter formulae: the formulae to get dependencies for
    /// - Returns: a set of outcoming dependencies
    func outcomingDependencies(for formulae: String) -> Set<String>

    /// Get incoming dependencies for a formulae
    ///
    /// - Parameter formulae: the formulae to get dependencies for
    /// - Returns: a set of incoming dependencies
    func incomingDependencies(for formulae: String) -> Set<String>

    // MARK: Notifications

    /// Write the data base to a permenant storage
    func write()
}
