//
//  EncodableCacheTest.swift
//  BrewExtensionTests
//
//  Created by Zehua Chen on 8/15/19.
//

import XCTest
@testable import BrewExtension

class EncodableCacheTest: XCTestCase {
    func testLabels() {
        let cache = EncodableCache()
        let lifeLabel = EncodableCache.Label(name: "life")

        cache.addLabel(lifeLabel)
        XCTAssertTrue(cache.containsLabel(lifeLabel))
    }
}
