//
//  SqlDataBase.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

import BrewExtension
import Foundation

class JsonDataBase: GraphBasedBrewExtensionDataBase {

    static func createOrLoad(from path: String) -> JsonDataBase {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let manager = FileManager.default

        if !manager.fileExists(atPath: url.path) {
            try! manager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }

        return JsonDataBase(url: url)
    }

    var formulaes = Graph<String, FormulaeInfo>()
    var labels = [String: Set<String>]()

    /// URL where the data base is stored
    var url: URL
    var formulaesURL: URL
    var labelsURL: URL

    /// Initialize a json data base
    ///
    /// - Parameter url: the url that points to a folder where the data base
    /// stores its content
    init(url: URL) {
        self.url = url
        self.formulaesURL = self.url.appendingPathComponent("formulaes.json")
        self.labelsURL = self.url.appendingPathComponent("labels.json")

        try! _loadLabels()
        try! _loadFormulaes()
    }

    func write() {
        try! _saveFormulaes()
        try! _saveLabels()
    }

    deinit {
        self.write()
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
        guard let data = try? Data(contentsOf: self.formulaesURL) else { return }

        self.formulaes = try decoder.decode(Graph<String, FormulaeInfo>.self, from: data)
    }

    fileprivate func _loadLabels() throws {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: self.labelsURL) else { return }

        self.labels = try decoder.decode([String: Set<String>].self, from: data)
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
