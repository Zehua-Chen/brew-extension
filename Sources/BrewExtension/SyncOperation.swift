//
//  SyncOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/15/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

public protocol SyncOperation {
    func run<C: Cache>(with cache: inout C, using brew: Brew) throws
}

public extension SyncOperation {
    func run<C: Cache>(with cache: inout C, using brew: Brew) throws {
        let rawInfos = try brew.info(of: try brew.list())
        let rawNames = Set(rawInfos.lazy.map { return $0.name })

        // Add formulaes that are not in the cache

        for rawInfo in rawInfos {
            if !cache.containsFormulae(rawInfo.name) {
                cache.addFormulae(rawInfo.name)
            }
        }

        // Remove cached formulaes that are no longer in homebrew

        for formulae in cache.formulaes() {
            if !rawNames.contains(formulae.name) {
                cache.removeFormulae(formulae.name)
            }
        }

        // build connections

        for rawInfo in rawInfos {
            let name = rawInfo.name

            for dep in rawInfo.deps {
                // Dependency relation is only constructed between
                // installed formulaes
                if cache.containsFormulae(dep) && !cache.containsDependency(from: name, to: dep) {
                    cache.addDependency(from: name, to: dep)
                }
            }
        }
    }
}
