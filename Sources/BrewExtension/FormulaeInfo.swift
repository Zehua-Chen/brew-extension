//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo: Encodable, Decodable {
    var isUserPackage: Bool
    var labels: Set<String>

    public init(isUserPackage: Bool = false, labels: [String] = .init()) {
        self.isUserPackage = isUserPackage
        self.labels = Set(labels)
    }
}
