//
//  FindUninstallablesOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

public protocol FindUninstallablesOperationDataSource {
    func formulaes() -> [String]
    func outcomingDependencies(for name: String) -> Set<String>
    func protectsFormulae(_ name: String) -> Bool
}

public protocol FindUninstallablesOperation {
    func findUninstallableFormulaes<
        DataSource: FindUninstallablesOperationDataSource
    >(for formulae: String, using dataSource: DataSource) -> [String]
}

public extension FindUninstallablesOperation {
    func findUninstallableFormulaes<
        DataSource: FindUninstallablesOperationDataSource
    >(for formulae: String, using dataSource: DataSource) -> [String] {
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

        guard graph.contains(formulae) else { return [] }

        var uninstalls = [String]()

        var set = Set<String>()
        set.insert(formulae)

        while let current = set.popFirst() {
            let incomings = graph.incomings(for: current)!
            let isProtected = graph.data(for: current)!

            guard incomings.isEmpty else { continue }

            if (isProtected && current == formulae) || !isProtected {
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
