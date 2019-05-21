//
//  Brew.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Foundation

public final class Brew {

    public enum ProcessError: Error {
        case stdout
        case decoding
    }

    public static let url = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")

    public static func deps(for name: String) throws -> [String] {
        let output = try _run(url: url, args: ["deps", name])
        return _parseTable(output)
    }

    public static func list() throws -> [String] {
        let output = try _run(url: url, args: ["list"])
        return _parseTable(output)
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

    fileprivate static func _run(url: URL, args: [String]) throws -> String {
        let process = Process()
        process.arguments = args
        process.executableURL = url
        process.standardOutput = Pipe()

        process.launch()

        guard let outputPipe = process.standardOutput as? Pipe else {
            throw ProcessError.stdout
        }

        guard let text = String(
            data: outputPipe.fileHandleForReading.availableData,
            encoding: .utf8) else {
            throw ProcessError.decoding
        }

        return text
    }
}
