//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo: Encodable, Decodable {
    var isUserPackage: Bool
    var folder: String

    public init(isUserPackage: Bool = false, folder: String = "") {
        self.isUserPackage = isUserPackage
        self.folder = folder
    }
}
