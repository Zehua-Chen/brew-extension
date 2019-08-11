//
//  FormulaeInfo.swift
//  Brew
//
//  Created by Zehua Chen on 5/22/19.
//

public struct FormulaeInfo: Encodable, Decodable {
    var isUserPackage = false
    var folder = ""
    
    public init() {}
    
    public init(isUserPackage: Bool, folder: String) {
        self.isUserPackage = isUserPackage
        self.folder = folder
    }
}
