//
//  GraphBasedBrewExtensionDataSource.swift
//  Brew
//
//  Created by Zehua Chen on 8/12/19.
//

public protocol GraphBasedBrewExtensionDataBase: BrewExtensionDataBase {
    var formulaes: Graph<String, FormulaeInfo> { get set }
    var labels: [String: Set<String>] { get set }
}

// MARK: Default Implementation

public extension GraphBasedBrewExtensionDataBase {

    func labels(of formulae: String) -> Set<String> {
        guard let data = self.formulaes.data(for: formulae) else { return .init() }
        return data.labels
    }

    func removeLabel(_ label: String, from formulae: String) {
        self.labels[label]?.remove(formulae)
        self.formulaes[formulae]?.labels.remove(label)
    }

    func addLabel(_ label: String, to formulae: String) {
        self.formulaes[formulae]?.labels.insert(label)
        self.labels[label]?.insert(formulae)
    }

    func createLabel(_ label: String) {
        self.labels[label] = .init()
    }

    func removeLabel(_ label: String) {
        guard let formulaesInLabel = self.labels[label] else { return }

        for formulae in formulaesInLabel {
            self.formulaes[formulae]!.labels.remove(label)
        }

        self.labels.removeValue(forKey: label)
    }

    func hasLabel(_ label: String) -> Bool { return self.labels[label] != nil }

    // MARK: Protected Formulaes

    func protectFormulae(_ formulae: String) {
        self.formulaes[formulae]?.isProtected = true
    }

    func protectsFormulae(_ formulae: String) -> Bool {
        return self.formulaes[formulae]?.isProtected ?? false
    }

    func unprotectFormulae(_ formulae: String) {
        self.formulaes[formulae]?.isProtected = false
    }

    func formulaes(under label: String) -> Set<String> {
        return self.labels[label] ?? Set<String>()
    }

    // MARK: Formulaes
    func containsFormulae(_ formulae: String) -> Bool {
        return self.formulaes.contains(formulae)
    }

    func addFormulae(_ formulae: String) {
        self.formulaes.insert(formulae, with: .init())
    }

    func removeFormulae(_ formulae: String) {
        self.formulaes.remove(formulae)
    }

    // MARK: Formulae Dependencies
    
    func addDependency(from: String, to: String) {
        self.formulaes.connect(from: from, to: to)
    }

    func hasDependency(from: String, to: String) -> Bool {
        return self.formulaes.outcomings(for: from)?.contains(to) ?? false
    }

    func outcomingDependencies(for formulae: String) -> Set<String> {
        return self.formulaes.outcomings(for: formulae) ?? Set<String>()
    }

    func incomingDependencies(for formulae: String) -> Set<String> {
        return self.formulaes.incomings(for: formulae) ?? Set<String>()
    }
}
