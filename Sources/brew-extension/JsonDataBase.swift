//
//  SqlDataBase.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

import BrewExtension
import Foundation

struct JsonDataBase: DataBase {

    static func makeDefault(path: String) -> JsonDataBase {
        let url = URL(fileURLWithPath: path, isDirectory: true)
        let manager = FileManager.default

        if !manager.fileExists(atPath: url.path) {
            try! manager.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }

        return JsonDataBase(url: url)
    }

    var url: URL

    init(url: URL) {
        self.url = url
    }

    mutating func saveFormulaes(_ info: Graph<String, FormulaeInfo>) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(info)
        let rawJsonPath = "\(url.path)/raw.json"

        let manager = FileManager.default

        if manager.fileExists(atPath: rawJsonPath) {
            try! data.write(to: URL(fileURLWithPath: rawJsonPath))
        } else {
            manager.createFile(atPath: rawJsonPath, contents: data, attributes: nil)
        }
    }

    func loadFormulaes() -> Graph<String, FormulaeInfo> {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: URL(fileURLWithPath: "\(url.path)/raw.json"))

        return try! decoder.decode(Graph<String, FormulaeInfo>.self, from: data)
    }
}
