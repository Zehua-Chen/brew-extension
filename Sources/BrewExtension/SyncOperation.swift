//
//  SyncOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

/// A data source that provides data to a sync operation
public protocol SyncOperationDataSource {

    /// Determine if a formulae is present
    ///
    /// - Parameter name: the name of the formulae
    /// - Returns: if the formulae is present
    func containsFormulae(_ name: String) -> Bool

    /// Get a list of formulaes
    ///
    /// - Returns: an array of formulae names
    func formulaes() -> [String]

    /// Determine if a dependency exists between two formulaes
    ///
    /// - Parameters:
    ///   - sourceName: the name of the formulae where the dependency originates
    ///   - targetName: the name of the formulae where the dependency ends
    /// - Returns: if the dependency is found
    func containsDependency(from sourceName: String, to targetName: String) -> Bool

    /// Add a formulae
    ///
    /// - Parameter name: the name to be used on the added formulae
    mutating func addFormulae(_ name: String)

    /// Remove a formulae
    ///
    /// - Parameter name: the name of the formulae to remove
    mutating func removeFormulae(_ name: String)

    /// Add a dependency from one formulae to anothe formulae
    ///
    /// - Parameters:
    ///   - sourceName: the name of the formulae where the dependency originates
    ///   - targetName: the name of the formulae where the dependency ends
    mutating func addDependency(from sourceName: String, to targetName: String)
}

/// Sync data with homebrew and save the synced data into a datasource
public protocol SyncOperation {

   /// Sync data with homebrew
   ///
   /// - Parameters:
   ///   - dataSource: the datasource to write the synced information into
   ///   - brew: a brew object to get data from
   /// - Throws:
   func sync<DataSource: SyncOperationDataSource>(into dataSource: inout DataSource, brew: Brew) throws
}

// MARK: - Default Implementation of `SyncOperation`

public extension SyncOperation {
    func sync<DataSource: SyncOperationDataSource>(into dataSource: inout DataSource, brew: Brew) throws {
        let rawInfos = try brew.info(of: try brew.list())
        let rawNames = Set(rawInfos.lazy.map { return $0.name })

        // Add formulaes that are not in the cache

        for rawInfo in rawInfos {
            if !dataSource.containsFormulae(rawInfo.name) {
                dataSource.addFormulae(rawInfo.name)
            }
        }

        // Remove cached formulaes that are no longer in homebrew

        for formulae in dataSource.formulaes() {
            if !rawNames.contains(formulae) {
                dataSource.removeFormulae(formulae)
            }
        }

        // build connections

        for rawInfo in rawInfos {
            let name = rawInfo.name

            for dep in rawInfo.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if dataSource.containsFormulae(dep) && !dataSource.containsDependency(from: name, to: dep) {
                    dataSource.addDependency(from: name, to: dep)
                }
            }
        }
    }
}
