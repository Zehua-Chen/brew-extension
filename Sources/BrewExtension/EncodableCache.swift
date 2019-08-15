//
//  GraphBasedBrewExtensionDataSource.swift
//  Brew
//
//  Created by Zehua Chen on 8/12/19.
//

/// A cache implementation that can be either encoded or decoded
open class EncodableCache: Cache, Encodable, Decodable {

    public struct Label: LabelProtocol, Hashable, Encodable, Decodable {
        public var name: String

        public static func ==(lhs: Label, rhs: Label) -> Bool {
            return lhs.name == rhs.name
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.name)
        }
    }

    public struct Formulae: FormulaeProtocol, Hashable, Encodable, Decodable {
        public var name: String
        public var isProtected: Bool

        public static func ==(lhs: Formulae, rhs: Formulae) -> Bool {
            return lhs.name == rhs.name && lhs.isProtected == rhs.isProtected
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.name)
            hasher.combine(self.isProtected)
        }
    }

    fileprivate var _outcomings = [String: Set<String>]()
    fileprivate var _incomings = [String: Set<String>]()
    fileprivate var _formulaesToLabels = [String: Set<String>]()
    fileprivate var _labelsToFormulaes = [String: Set<String>]()
    fileprivate var _labels = [String: Label]()
    fileprivate var _formulaes = [String: Formulae]()

    open func labels(of formulae: String) -> Set<Label> {
        guard let labelIds = _formulaesToLabels[formulae] else { return .init() }
        return Set(labelIds.lazy.map { return self._labels[$0]! })
    }

    open func labels() -> [Label] {
        return _labels.map { return $0.value }
    }

    open func formulaes(under label: String) -> Set<Formulae> {
        guard let formulaeIds = _labelsToFormulaes[label] else { return .init() }
        return Set(formulaeIds.lazy.map { return self._formulaes[$0]! })
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
        _labels[label] = .init(name: label)
    }

    open func removeLabel(_ label: String) {

        for formulae in _labelsToFormulaes[label]! {
            _formulaesToLabels[formulae]!.remove(label)
        }

        _labelsToFormulaes.removeValue(forKey: label)
        _labels.removeValue(forKey: label)
    }

    open func containsLabel(_ label: String) -> Bool {
        return _labels[label] != nil
    }

    open func protectFormulae(_ formulae: String) {
        _formulaes[formulae]!.isProtected = true
    }

    open func protectsFormulae(_ formulae: String) -> Bool {
        return _formulaes[formulae]!.isProtected
    }

    open func unprotectFormulae(_ formulae: String) {
        _formulaes[formulae]!.isProtected = false
    }

    open func containsFormulae(_ formulae: String) -> Bool {
        return _formulaes[formulae] != nil
    }

    open func addFormulae(_ formulae: String) {
        _formulaes[formulae] = .init(name: formulae, isProtected: false)
    }

    open func removeFormulae(_ formulae: String) {
        _formulaes.removeValue(forKey: formulae)
    }

    open func formulaes() -> [Formulae] {
        return _formulaes.map { return $0.value }
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

    open func outcomingDependencies(for formulae: String) -> Set<Formulae> {
        guard let outcomingAt = _outcomings[formulae] else { return .init() }
        return Set(outcomingAt.lazy.map { return self._formulaes[$0]! })
    }

    open func incomingDependencies(for formulae: String) -> Set<Formulae> {
        guard let incomingsAt = _incomings[formulae] else { return .init() }
        return Set(incomingsAt.lazy.map { return self._formulaes[$0]! })
    }
}
