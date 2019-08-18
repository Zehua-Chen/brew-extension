//
//  GraphBasedBrewExtensionDataSource.swift
//  Brew
//
//  Created by Zehua Chen on 8/12/19.
//

/// A cache implementation that can be either encoded or decoded
open class EncodableCache:
    UninstallOperationDataSource,
    FindUninstallablesOperationDataSource,
    SyncOperationDataSource,
    Encodable,
    Decodable {

    fileprivate var _outcomings = [String: Set<String>]()
    fileprivate var _incomings = [String: Set<String>]()
    fileprivate var _formulaesToLabels = [String: Set<String>]()
    fileprivate var _labelsToFormulaes = [String: Set<String>]()
    fileprivate var _labels = Set<String>()
    fileprivate var _formulaes = Set<String>()
    fileprivate var _protectedFormulaes = Set<String>()

    public init() {}

    open func labels(of formulae: String) -> Set<String> {
        return _formulaesToLabels[formulae] ?? .init()
    }

    open func labels() -> [String] {
        return Array(_labels)
    }

    open func formulaes(under label: String) -> Set<String> {
        return _labelsToFormulaes[label] ?? .init()
    }

    open func removeLabel(_ label: String, from formulae: String) {
        _formulaesToLabels[formulae]!.remove(label)
        _labelsToFormulaes[label]!.remove(formulae)
    }

    open func addLabel(_ label: String, to formulae: String) {
        if _formulaesToLabels[formulae] == nil {
            _formulaesToLabels[formulae] = .init()
        }

        _formulaesToLabels[formulae]!.insert(label)

        if _labelsToFormulaes[label] == nil {
            _labelsToFormulaes[label] = .init()
        }

        _labelsToFormulaes[label]!.insert(formulae)
    }

    open func addLabel(_ label: String) {
        _labels.insert(label)
    }

    open func removeLabel(_ label: String) {

        for formulae in _labelsToFormulaes[label]! {
            _formulaesToLabels[formulae]!.remove(label)
        }

        _labelsToFormulaes.removeValue(forKey: label)
        _labels.remove(label)
    }

    open func containsLabel(_ label: String) -> Bool {
        return _labels.contains(label)
    }

    open func protectFormulae(_ formulae: String) {
        _protectedFormulaes.insert(formulae)
    }

    open func protectsFormulae(_ formulae: String) -> Bool {
        return _protectedFormulaes.contains(formulae)
    }

    open func unprotectFormulae(_ formulae: String) {
        _protectedFormulaes.remove(formulae)
    }

    open func containsFormulae(_ formulae: String) -> Bool {
        return _formulaes.contains(formulae)
    }

    open func addFormulae(_ formulae: String) {
        _formulaes.insert(formulae)
    }

    open func removeFormulae(_ formulae: String) {
        _formulaes.remove(formulae)
    }

    open func formulaes() -> [String] {
        return Array(_formulaes)
    }

    open func addDependency(from: String, to: String) {
        if _outcomings[from] == nil {
            _outcomings[from] = Set()
        }

        _outcomings[from]!.insert(to)

        if _incomings[to] == nil {
            _incomings[to] = Set()
        }

        _incomings[to]?.insert(from)
    }

    open func containsDependency(from: String, to: String) -> Bool {
        return _outcomings[from]?.contains(to) ?? false
    }

    open func outcomingDependencies(for formulae: String) -> Set<String> {
        return _outcomings[formulae] ?? .init()
    }

    open func incomingDependencies(for formulae: String) -> Set<String> {
        return _incomings[formulae] ?? .init()
    }
}
