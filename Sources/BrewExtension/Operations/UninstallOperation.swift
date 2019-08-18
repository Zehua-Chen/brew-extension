//
//  UninstallOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

/// A data source that provides data to an uninstall operation
public protocol UninstallOperationDataSource {

    /// If the formulae is present in the data source
    ///
    /// - Parameter name: name of the formulae
    /// - Returns: true if exists, false otherwise
    func containsFormulae(_ name: String) -> Bool

    /// Get labels of a formulae
    ///
    /// - Parameter formulaeName: the name of the formulae
    /// - Returns: a set of label names
    func labels(of formulaeName: String) -> Set<String>

    /// Remove a lable from a formulae
    ///
    /// - Parameters:
    ///   - labelName: the name of the label
    ///   - formulaeName: the name of the formulae
    mutating func removeLabel(_ labelName: String, from formulaeName: String)

    /// Remove a formulae from the database
    ///
    /// All related inforamtion of a formulae should be removed
    /// - Parameter name: name of the formulae to remove
    mutating func removeFormulae(_ name: String)
}

/// An operation that uninstall an formulae
public protocol UninstallOperation {

    /// Uninstall a formulae
    ///
    /// - Parameters:
    ///   - formulaeName: the name of the formulae
    ///   - brew: brew used to uninstall the formulae
    ///   - dataSource: a data source used to gather information of
    /// - Throws:
    func uninstallFormulae<
        DataSource: UninstallOperationDataSource
    >(_ formulaeName: String, with brew: Brew, using dataSource: inout DataSource) throws
}

public extension UninstallOperation {
    func uninstallFormulae<
        DataSource: UninstallOperationDataSource
    >(_ formulaeName: String, with brew: Brew, using dataSource: inout DataSource) throws {
        guard dataSource.containsFormulae(formulaeName) else { return }

        dataSource.removeFormulae(formulaeName)
        try brew.uninstallFormulae(formulaeName)
    }
}
