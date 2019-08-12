//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo: Encodable, Decodable {
    var isProtected: Bool
    var labels: Set<String>

    public init(isProtected: Bool = false, labels: Set<String> = .init()) {
        self.isProtected = isProtected
        self.labels = Set(labels)
    }
}
