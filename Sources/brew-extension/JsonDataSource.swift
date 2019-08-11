//
//  SqlDataBase.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

import BrewExtension
import Foundation

class JsonDataSource: BrewExtensionDataSource {

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
    var labelsURL: URL

    var formulaes: BrewExtension.Formulaes = .init()

    var labels: BrewExtension.Labels = .init()

    func flush() throws {
        try _saveFormulaes()
        try _saveLabels()
    }

    func load() throws {
        try _loadFormulaes()
        try _loadLabels()
    }

    /// Initialize a json data base
    ///
    /// - Parameter url: the url that points to a folder where the data base
    /// stores its content
    init(url: URL) {
        self.url = url
        self.formulaesURL = self.url.appendingPathComponent("formulaes.json")
        self.labelsURL = self.url.appendingPathComponent("labels.json")
    }

    fileprivate func _saveFormulaes() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self.formulaes)
#if DEBUG
        encoder.outputFormatting = .prettyPrinted
#endif

        try _writeData(data, url: self.formulaesURL)
    }

    fileprivate func _saveLabels() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self.labels)

        try _writeData(data, url: self.labelsURL)
    }

    fileprivate func _loadFormulaes() throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: self.formulaesURL)
        let decoded = try decoder.decode(BrewExtension.Formulaes.self, from: data)

        self.formulaes = decoded
    }

    fileprivate func _loadLabels() throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: self.labelsURL)
        let decoded = try decoder.decode(BrewExtension.Labels.self, from: data)

        self.labels = decoded
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
