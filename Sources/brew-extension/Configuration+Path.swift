//
//  File.swift
//  
//
//  Created by Zehua Chen on 11/28/19.
//

import SwiftArgParse
import BrewExtension

extension Configuration {
    func usePathOption() {
        self.use(Option(name: "--path", defaultValue: EncodableDataSource.defaultPath))
    }
}
