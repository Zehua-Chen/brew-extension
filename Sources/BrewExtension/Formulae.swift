//
//  Formulae.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct Formulae: Hashable, ExpressibleByStringLiteral {

    public typealias StringLiteralType = String

    public enum Action {
        case nothing
        case remove
    }

    public var action: Action
    public var name: String

    public init(name: String) {
        self.name = name
        self.action = .nothing
    }

    public init(name: String, action: Action) {
        self.name = name
        self.action = action
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(name: value)
    }

    public static func ==(lhs: Formulae, rhs: Formulae) -> Bool {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
