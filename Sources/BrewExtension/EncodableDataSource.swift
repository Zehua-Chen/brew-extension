//
//  GraphBasedBrewExtensionDataSource.swift
//  Brew
//
//  Created by Zehua Chen on 8/12/19.
//

/// A data source implementation that can be either encoded or decoded
open class EncodableDataSource:
    DataSource,
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

    /// Get the labels of a formulae
    ///
    /// - Parameter formulaeName: the name of the formulae to look up
    /// - Returns: a list of labels
    open func labels(of formulaeName: String) -> Set<String> {
        return _formulaesToLabels[formulaeName] ?? .init()
    }

    open func labels() -> [String] {
        return Array(_labels)
    }

    open func formulaes(under labelName: String) -> Set<String> {
        return _labelsToFormulaes[labelName] ?? .init()
    }

    open func removeLabel(_ labelName: String, from formulaeName: String) {
        _formulaesToLabels[formulaeName]!.remove(labelName)
        _labelsToFormulaes[labelName]!.remove(formulaeName)
    }

    open func addLabel(_ labelName: String, to formulaeName: String) {
        if _formulaesToLabels[formulaeName] == nil {
            _formulaesToLabels[formulaeName] = .init()
        }

        _formulaesToLabels[formulaeName]!.insert(labelName)

        if _labelsToFormulaes[labelName] == nil {
            _labelsToFormulaes[labelName] = .init()
        }

        _labelsToFormulaes[labelName]!.insert(formulaeName)
    }

    open func addLabel(_ name: String) {
        _labels.insert(name)
    }

    open func removeLabel(_ name: String) {

        for formulae in _labelsToFormulaes[name]! {
            _formulaesToLabels[formulae]!.remove(name)
        }

        _labelsToFormulaes.removeValue(forKey: name)
        _labels.remove(name)
    }

    open func containsLabel(_ name: String) -> Bool {
        return _labels.contains(name)
    }

    open func protectFormulae(_ name: String) {
        _protectedFormulaes.insert(name)
    }

    open func protectsFormulae(_ name: String) -> Bool {
        return _protectedFormulaes.contains(name)
    }

    open func unprotectFormulae(_ name: String) {
        _protectedFormulaes.remove(name)
    }

    open func containsFormulae(_ name: String) -> Bool {
        return _formulaes.contains(name)
    }

    open func addFormulae(_ name: String) {
        _formulaes.insert(name)
    }

    open func removeFormulae(_ name: String) {
        // Remove dependencies
        if let outcomings = _outcomings[name] {
            for outcoming in outcomings {
                _incomings[outcoming]!.remove(name)
            }
        }

        if let incomings = _incomings[name] {
            for incoming in incomings {
                _outcomings[incoming]!.remove(name)
            }
        }

        _outcomings.removeValue(forKey: name)
        _incomings.removeValue(forKey: name)

        // Remove formulae from associated labels

        if let associatedLabels = _formulaesToLabels[name] {
            for label in associatedLabels {
                _labelsToFormulaes[label]!.remove(name)
            }
        }

        _formulaesToLabels.removeValue(forKey: name)

        // Remove formulae

        _protectedFormulaes.remove(name)
        _formulaes.remove(name)
    }

    open func formulaes() -> [String] {
        return Array(_formulaes)
    }

    open func addDependency(from sourceName: String, to targetName: String) {
        if _outcomings[sourceName] == nil {
            _outcomings[sourceName] = Set()
        }

        _outcomings[sourceName]!.insert(targetName)

        if _incomings[targetName] == nil {
            _incomings[targetName] = Set()
        }

        _incomings[targetName]!.insert(sourceName)
    }

    open func containsDependency(from sourceName: String, to targetName: String) -> Bool {
        return _outcomings[sourceName]?.contains(targetName) ?? false
    }

    open func outcomingDependencies(for name: String) -> Set<String> {
        return _outcomings[name] ?? .init()
    }

    open func incomingDependencies(for name: String) -> Set<String> {
        return _incomings[name] ?? .init()
    }
}
