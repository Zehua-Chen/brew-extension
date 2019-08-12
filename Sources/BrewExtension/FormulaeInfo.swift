//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo: Encodable, Decodable {
    public var isProtected: Bool
    public var labels: Set<String>

    public init(isProtected: Bool = false, labels: Set<String> = .init()) {
        self.isProtected = isProtected
        self.labels = Set(labels)
    }
}
