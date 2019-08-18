//
//  ASTContextExtension.swift
//  brew-extension
//
//  Created by Zehua Chen on 8/16/19.
//

import SwiftArgParse
import Foundation
import BrewExtension

extension EncodableDataSource {
    static func load(with context: ASTContext) -> EncodableDataSource {
        guard let data = try? Data(contentsOf: .init(fileURLWithPath: context.namedParams["--path"] as! String)) else {
            return .init()
        }

        let decoder = JSONDecoder()
        return try! decoder.decode(EncodableDataSource.self, from: data)
    }

    func save(with context: ASTContext) {
        let url = URL(fileURLWithPath: context.namedParams["--path"] as! String)
        let encoder = JSONEncoder()

        try! (try! encoder.encode(self)).write(to: url)
    }
}
