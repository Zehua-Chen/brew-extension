//
//  Formulae.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo {
    public enum Action {
        case nothing
        case uninstall
    }

    var action = Action.nothing

    public init() {}
}
