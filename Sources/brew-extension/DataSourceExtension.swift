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

    static var defaultPath = "\(NSHomeDirectory())/.brew-extension"

    static func load(with context: CommandContext) -> EncodableDataSource {
        guard let data = try? Data(contentsOf: .init(fileURLWithPath: context.options["--path"] as! String)) else {
            return .init()
        }

        let decoder = JSONDecoder()
        return try! decoder.decode(EncodableDataSource.self, from: data)
    }

    func save(with context: CommandContext) {
        let url = URL(fileURLWithPath: context.options["--path"] as! String)
        let encoder = JSONEncoder()

        try! (try! encoder.encode(self)).write(to: url)
    }
}
