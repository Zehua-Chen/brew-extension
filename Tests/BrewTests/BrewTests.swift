import XCTest
@testable import Brew
import Foundation

final class BrewTests: XCTestCase {

    func testList() {
        let input = """
aria2       git-lfs        libtiff        openssl        sqlite
clang-format    icarus-verilog    mongodb        pkg-config    xz
"""
        let formulaes = Brew._parseList(using: input)
        let expected: [Formulae] = [
            .init(name: "aria2"),
            .init(name: "git-lfs"),
            .init(name: "libtiff"),
            .init(name: "openssl"),
            .init(name: "sqlite"),
            .init(name: "clang-format"),
            .init(name: "icarus-verilog"),
            .init(name: "mongodb"),
            .init(name: "pkg-config"),
            .init(name: "xz"),
        ]

        XCTAssertEqual(formulaes, expected)
    }

    func testDeps() {

    }
}
