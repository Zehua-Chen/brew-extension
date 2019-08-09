//
//  SqlDataBase.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

import BrewExtension
import Foundation

struct JsonDataBase: DataBase {

    static func createOrLoad(from path: String) -> JsonDataBase {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let manager = FileManager.default

        if !manager.fileExists(atPath: url.path) {
            try! manager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }

        return JsonDataBase(url: url)
    }

    var folderURL: URL
    var fileURL: URL

    /// Initialize a json data base
    ///
    /// - Parameter url: the url that points to a folder where the data base
    /// stores its content
    init(url: URL) {
        self.folderURL = url
        self.fileURL = self.folderURL.appendingPathComponent("formulaes.json")
    }

    mutating func saveFormulaes(_ info: Graph<String, FormulaeInfo>) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(info)

        let manager = FileManager.default

        if manager.fileExists(atPath: self.fileURL.path) {
            try! data.write(to: self.fileURL)
        } else {
            manager.createFile(atPath: self.fileURL.path, contents: data, attributes: nil)
        }
    }

    func loadFormulaes() -> Graph<String, FormulaeInfo> {
        let decoder = JSONDecoder()

        guard let data = try? Data(contentsOf: fileURL) else {
            return .init()
        }

        return try! decoder.decode(Graph<String, FormulaeInfo>.self, from: data)
    }
}
