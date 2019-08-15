//
//  FindUninstallablesOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

public protocol FindUninstallablesOperation {
    func findUninstallFormulae<C: Cache>(for formulae: String, cache: C) -> [C.Formulae]
}

public extension FindUninstallablesOperation {
    func findUninstallFormulae<C: Cache>(for formulae: String, cache: C) -> [C.Formulae] {
        // MARK: Create a copy of the cache's graph
        var graph = _Graph<String, C.Formulae>()
        let formulaes = cache.formulaes()

        for formulae in formulaes {
            graph.insert(formulae.name, with: formulae)
        }

        for formulae in formulaes {
            let outcomings = cache.outcomingDependencies(for: formulae.name)

            for outcoming in outcomings {
                graph.connect(from: formulae.name, to: outcoming.name)
            }
        }

        // MARK: Find removables

        guard graph.contains(formulae) else { return [] }

        var uninstalls = [C.Formulae]()

        var dict = [String: C.Formulae]()
        dict[formulae] = graph.data(for: formulae)!

        while let current = dict.popFirst() {
            let incomings = graph.incomings(for: current.key)!
            let data = current.value

            guard incomings.isEmpty else { continue }

            if (data.isProtected && current.key == formulae) || !data.isProtected {
                let outcomings = graph.outcomings(for: current.key)!

                for outcoming in outcomings {
                    if dict[outcoming] == nil {
                        dict[outcoming] = graph.data(for: outcoming)!
                    }
                }

                graph.remove(current.key)
                uninstalls.append(current.value)
            }
        }

        return uninstalls
    }
}
