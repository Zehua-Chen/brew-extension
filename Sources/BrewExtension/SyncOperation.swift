//
//  SyncOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

public protocol SyncOperationDataSource {
    func containsFormulae(_ name: String) -> Bool
    mutating func addFormulae(_ name: String)
    mutating func removeFormulae(_ name: String)
    func formulaes() -> [String]

    func containsDependency(from name: String, to name: String) -> Bool
    mutating func addDependency(from name: String, to name: String)
}

public protocol SyncOperation {
   func sync<DataSource: SyncOperationDataSource>(into dataSource: inout DataSource, brew: Brew) throws
}

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
