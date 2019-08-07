//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 8/8/19.
//

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
