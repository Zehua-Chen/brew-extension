//
//  FindUninstallablesOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

/// A data source that provides data to a find uninstallable operation
public protocol FindUninstallablesOperationDataSource {

    /// Provide an array of formulaes
    ///
    /// - Returns: an array of formulaes
    func formulaes() -> [String]

    /// Provide the outcoming dependencies of a formulae
    ///
    /// - Parameter formulaeName: the formulae name used to look up dependencies
    /// - Returns: a set of dependencies in name
    func outcomingDependencies(for formulaeName: String) -> Set<String>

    /// Determine if a formulae is protected
    ///
    /// - Parameter name: the name of the formulae
    /// - Returns: true or false
    func protectsFormulae(_ name: String) -> Bool
}

/// An operation that finds all the formulases that can be uninstalled
/// given a target formulae
public protocol FindUninstallablesOperation {

    /// Find formulaes that can be uninstalled
    ///
    /// - Parameters:
    ///   - name: the name of the formulae to uninstall
    ///   - dataSource: the data source from which to get information from
    /// - Returns: an array of uninstallable formulae, including the
    ///   the provided target formlae
    func findUninstallableFormulaes<
        DataSource: FindUninstallablesOperationDataSource
    >(for name: String, using dataSource: DataSource) -> [String]
}

// MARK: - Default Implementtation of `FindUninstallablesOperation`

public extension FindUninstallablesOperation {
    
    func findUninstallableFormulaes<
        DataSource: FindUninstallablesOperationDataSource
    >(for name: String, using dataSource: DataSource) -> [String] {
        // MARK: Create a copy of the cache's graph
        var graph = _Graph<String, Bool>()
        let formulaes = dataSource.formulaes()

        for formulae in formulaes {
            graph.insert(formulae, with: dataSource.protectsFormulae(formulae))
        }

        for formulae in formulaes {
            let outcomings = dataSource.outcomingDependencies(for: formulae)

            for outcoming in outcomings {
                graph.connect(from: formulae, to: outcoming)
            }
        }

        // MARK: Find removables

        guard graph.contains(name) else { return [] }

        var uninstalls = [String]()

        var set = Set<String>()
        set.insert(name)

        while let current = set.popFirst() {
            let incomings = graph.incomings(for: current)!
            let isProtected = graph.data(for: current)!

            guard incomings.isEmpty else { continue }

            if (isProtected && current == name) || !isProtected {
                let outcomings = graph.outcomings(for: current)!

                for outcoming in outcomings {
                    if !set.contains(outcoming) {
                        set.insert(outcoming)
                    }
                }

                graph.remove(current)
                uninstalls.append(current)
            }
        }

        return uninstalls
    }
}
