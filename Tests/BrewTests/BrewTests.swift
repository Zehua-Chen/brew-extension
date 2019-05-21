//
//  BrewTests.swift
//  BrewExtension
//
//  Created by Zehua Chen on 5/20/19.
//

import XCTest
@testable import Brew
import Foundation

final class BrewTests: XCTestCase {

    func testParseMultiColTable() {
        let brew = Brew()
        let table = """
aria2       git-lfs        libtiff        openssl        sqlite
clang-format    icarus-verilog    mongodb        pkg-config    xz
"""
        let formulaes = brew._parseTable(table)
        let expected: [String] = [
            "aria2",
            "git-lfs",
            "libtiff",
            "openssl",
            "sqlite",
            "clang-format",
            "icarus-verilog",
            "mongodb",
            "pkg-config",
            "xz",
        ]

        XCTAssertEqual(formulaes, expected)
    }

    func testParseSingleColTable() {
        let brew = Brew()
        let table = """
libffi
pcre
swig
"""
        let formulaes = brew._parseTable(table)
        let expected: [String] = ["libffi", "pcre", "swig"]

        XCTAssertEqual(formulaes, expected)
    }
}
