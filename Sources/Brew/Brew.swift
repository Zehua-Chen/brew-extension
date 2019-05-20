//
//  Brew.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Foundation

public final class Brew {
    public static let url = URL(fileURLWithPath: "")

    public static func deps(for name: String) -> [String] {
        return []
    }

    public static var list: [String] {
        return []
    }

    internal static func _parseTable(_ table: String) -> [String] {
        var formulaes = [String]()
        var buffer = ""

        for letter in table {
            switch letter {
            case " ", "\t", "\n":
                if !buffer.isEmpty {
                    formulaes.append(buffer)
                    buffer.removeAll()
                }
            case "\r":
                continue
            default:
                buffer.append(letter)
            }
        }

        if !buffer.isEmpty {
            formulaes.append(buffer)
        }

        return formulaes
    }
}
