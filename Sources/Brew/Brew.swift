//
//  Brew.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import Foundation

/// Interface to Homebrew
public struct Brew {

    /// Errors thrown during the execution of homebrew
    public enum BrewError: Error {
        /// stdout error occurs if it fails to read brew process'
        /// standard output
        case stdout
        /// decoding error occurs if there is something wrong decoding
        /// brew process's standard output
        case decoding
    }

    public struct FormulaeInfo: Decodable, CustomStringConvertible {

        fileprivate enum Keys: CodingKey {
            case name
            case dependencies
            case build_dependencies
        }

        public var name: String
        public var deps: [String]

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Keys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.deps = try container.decode(Array<String>.self, forKey: .dependencies)
            self.deps.append(contentsOf: try container.decode(Array<String>.self, forKey: .build_dependencies))
        }

        public var description: String {
            return "name = \(self.name), deps = \(self.deps)"
        }
    }

    /// URL to homebrew executable
    public let url: URL

    public init(
        url: URL = URL(fileURLWithPath: "/usr/local/Homebrew/bin/brew")
    ) {
        self.url = url
    }

    /// Get the dependencies of a formulae
    ///
    /// - Parameter name: the name of the formulae
    /// - Returns: a list of dependencies of the formulae
    /// - Throws: ProcessError if something go wrong running brew
    public func deps(for name: String) throws -> [String] {
        let output: String = try _run(args: ["deps", name])
        return _parseTable(output)
    }

    public func info(for names: [String]) throws -> [FormulaeInfo] {
        var args = ["info", "--json"]
        args.append(contentsOf: names)

        let output: Data = try _run(args: args)
        print(String(data: output, encoding: .utf8)!)
        let decoder = JSONDecoder()
        return try decoder.decode(Array<FormulaeInfo>.self, from: output)
    }

    public func uninstall(formulae name: String) throws {
        let _: String = try _run(args: ["uninstall", name])
    }

    /// Get a list of installed homebrew packages
    ///
    /// - Returns: name of homebrew packages
    /// - Throws: ProcessError if something go wrong running brew
    public func list() throws -> [String] {
        let output: String = try _run(args: ["list"])
        return _parseTable(output)
    }

    /// Parse table printed by homebrew
    ///
    /// - Parameter table: the table string to parse
    /// - Returns: parsed items of the table
    internal func _parseTable(_ table: String) -> [String] {
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

    /// Run command line application
    ///
    /// - Parameters:
    ///   - args: args to give to the executable
    /// - Returns: string standard output of the executable
    /// - Throws: ProcessError if something go wrong running brew
    fileprivate func _run(args: [String]) throws -> String {

        guard let text = String(
            data: try _run(args: args),
            encoding: .utf8) else {
            throw BrewError.decoding
        }

        return text
    }

    /// Run command line application
    ///
    /// - Parameters:
    ///   - args: args to give to the executable
    /// - Returns: standard output data of the executable
    /// - Throws: ProcessError if something go wrong running brew
    fileprivate func _run(args: [String]) throws -> Data {
        let process = Process()
        process.arguments = args
        process.executableURL = self.url
        process.standardOutput = Pipe()

        process.launch()

        guard let outputPipe = process.standardOutput as? Pipe else {
            throw BrewError.stdout
        }

        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }
}
