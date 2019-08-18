//
//  UninstallOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

public protocol UninstallOperationDataSource {
    func containsFormulae(_ name: String) -> Bool
    func labels(of formulaeName: String) -> Set<String>
    mutating func removeLabel(_ labelName: String, from formulaeName: String)
    mutating func removeFormulae(_ name: String)
}

public protocol UninstallOperation {
    func uninstallFormulae<
        DataSource: UninstallOperationDataSource
    >(_ formulae: String, with brew: Brew, using dataSource: inout DataSource) throws
}

public extension UninstallOperation {
    func uninstallFormulae<
        DataSource: UninstallOperationDataSource
    >(_ formulae: String, with brew: Brew, using dataSource: inout DataSource) throws {
        guard dataSource.containsFormulae(formulae) else { return }

        for label in dataSource.labels(of: formulae) {
            dataSource.removeLabel(label, from: formulae)
        }

        dataSource.removeFormulae(formulae)

        try brew.uninstallFormulae(formulae)
    }
}
