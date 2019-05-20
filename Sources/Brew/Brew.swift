//
//  Formulae.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Foundation

public final class Brew {
    public static let url = URL(fileURLWithPath: "")

    public static func deps(for formulae: Formulae) -> [Formulae] {
        return []
    }

    public static var list: [Formulae] {
        return []
    }

    internal static func _parseList(using text: String) -> [Formulae] {
        var formulaes = [Formulae]()
        var buffer = ""

        for letter in text {
            switch letter {
            case " ", "\t", "\n", "\r":
                if !buffer.isEmpty {
                    formulaes.append(Formulae(name: buffer))
                    buffer.removeAll()
                }
            default:
                buffer.append(letter)
            }
        }

        if !buffer.isEmpty {
            formulaes.append(Formulae(name: buffer))
        }

        return formulaes
    }

    internal static func _parseDeps(
        for formulae: Formulae,
        using text: String
    ) -> [Formulae] {
        return []
    }
}
