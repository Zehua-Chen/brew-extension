//
//  SqlDataBase.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

import BrewExtension
import Foundation

class JsonDataSource: BrewExtensionDataSource {
    func removeFormulae(_ formulae: String) throws {
    }

    func removeLabel(_ label: String) throws {
    }

    func labelFormulae(_ formulae: String, as labels: String) throws {
    }


    static func createOrLoad(from path: String) -> JsonDataSource {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let manager = FileManager.default

        if !manager.fileExists(atPath: url.path) {
            try! manager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }

        return JsonDataSource(url: url)
    }

    /// URL where the data base is stored
    var url: URL
    var formulaesURL: URL
    var foldersURL: URL

    /// Initialize a json data base
    ///
    /// - Parameter url: the url that points to a folder where the data base
    /// stores its content
    init(url: URL) {
        self.url = url
        self.formulaesURL = self.url.appendingPathComponent("formulaes.json")
        self.foldersURL = self.url.appendingPathComponent("folders.json")
    }

    func saveFormulaes(_ info: BrewExtension.Formulaes) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(info)

        try _writeData(data, url: self.formulaesURL)
    }

    func saveLabels(_ folders: BrewExtension.Labels) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(folders)

        try _writeData(data, url: self.foldersURL)
    }

    func loadFormulaes() throws -> BrewExtension.Formulaes {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: self.formulaesURL)
        let decoded = try decoder.decode(BrewExtension.Formulaes.self, from: data)

        return decoded
    }

    func loadLabels() throws -> BrewExtension.Labels {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: self.formulaesURL)
        let decoded = try decoder.decode(BrewExtension.Labels.self, from: data)

        return decoded
    }

    fileprivate func _writeData(_ data: Data, url: URL) throws {
        let manager = FileManager.default

        if manager.fileExists(atPath: url.path) {
            try data.write(to: url)
        } else {
            manager.createFile(atPath: url.path, contents: data, attributes: nil)
        }
    }
}
