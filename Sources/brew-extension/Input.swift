//
//  Input.swift
//  Brew
//
//  Created by Zehua Chen on 8/11/19.
//

protocol ConvertibleFromString {
    init?(_ description: String)
}

struct Input<T: ConvertibleFromString> {
    static func read(prompt: String, defaultValue: T) -> T {
        print("\(prompt): ", separator: "", terminator: "")

        guard let line = readLine() else { return defaultValue }
        guard let t = T(line) else { return defaultValue }

        return t
    }
}

extension Double: ConvertibleFromString {
}

extension Int: ConvertibleFromString {
}

extension Bool: ConvertibleFromString {
    init?(_ description: String) {
        switch description {
        case "t", "y", "true", "True":
            self = true
        case "f", "n", "false", "False":
            self = false
        default:
            return nil
        }
    }
}
