//
//  UninstallOperation.swift
//  Brew
//
//  Created by Zehua Chen on 8/16/19.
//

#if SWIFT_PACKAGE
    import Brew
#endif

public protocol UninstallOperation {
    func uninstallFormulae<C: Cache>(_ formulae: String, cache: inout C, brew: Brew) throws
}

public extension UninstallOperation {
    func uninstallFormulae<C: Cache>(_ formulae: String, cache: inout C, brew: Brew) throws {
        guard cache.containsFormulae(formulae) else { return }

        for label in cache.labels(of: formulae) {
            cache.removeLabel(label.name, from: formulae)
        }

        cache.removeFormulae(formulae)

        try brew.uninstallFormulae(formulae)
    }
}
