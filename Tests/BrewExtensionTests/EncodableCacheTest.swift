//
//  EncodableCacheTest.swift
//  BrewExtensionTests
//
//  Created by Zehua Chen on 8/15/19.
//

import XCTest
@testable import BrewExtension

class EncodableCacheTest: XCTestCase {

    func testFormulaes() {
        let database = EncodableCache()

        database.addFormulae("cmake")
        database.addFormulae("llvm")

        XCTAssertTrue(database.containsFormulae("cmake"))
        XCTAssertTrue(database.containsFormulae("llvm"))
        XCTAssertEqual(database.formulaes().count, 2)

        database.removeFormulae("cmake")
        XCTAssertFalse(database.containsFormulae("cmake"))

        database.removeFormulae("llvm")
        XCTAssertFalse(database.containsFormulae("llvm"))

        XCTAssertEqual(database.formulaes().count, 0)
    }

    func testDependencies() {
        let database = EncodableCache()

        database.addFormulae("cmake")
        database.addFormulae("llvm")
        database.addFormulae("open_cv")

        database.addDependency(from: "llvm", to: "cmake")
        XCTAssertTrue(database.containsDependency(from: "llvm", to: "cmake"))
        XCTAssertFalse(database.containsDependency(from: "cmake", to: "llvm"))

        database.addDependency(from: "cmake", to: "llvm")
        XCTAssertTrue(database.containsDependency(from: "cmake", to: "llvm"))

        database.addDependency(from: "open_cv", to: "llvm")

        let llvmIncomings = database.incomingDependencies(for: "llvm").map { return $0.name }
        XCTAssertEqual(llvmIncomings.count, 2)
        XCTAssertTrue(llvmIncomings.contains("cmake"))
        XCTAssertTrue(llvmIncomings.contains("open_cv"))

        database.addDependency(from: "cmake", to: "open_cv")

        let cmakeOutcomings = database.outcomingDependencies(for: "cmake").map { return $0.name }
        XCTAssertEqual(cmakeOutcomings.count, 2)
        XCTAssertTrue(cmakeOutcomings.contains("llvm"))
        XCTAssertTrue(cmakeOutcomings.contains("open_cv"))
    }

    func testProtection() {
        let database = EncodableCache()

        database.addFormulae("cmake")

        database.protectFormulae("cmake")
        XCTAssertTrue(database.protectsFormulae("cmake"))

        database.unprotectFormulae("cmake")
        XCTAssertFalse(database.protectsFormulae("cmake"))
    }

    func testLabels() {
        let database = EncodableCache()

        // MARK: Setup formulaes
        database.addFormulae("valgrind")
        database.addFormulae("aria2")
        database.addFormulae("cmake")

        // MARK: Setup labels
        database.addLabel("life")
        XCTAssertTrue(database.containsLabel("life"))

        database.addLabel("c++")
        XCTAssertEqual(database.labels().count, 2)

        database.addLabel("c++", to: "cmake")
        database.addLabel("c++", to: "valgrind")
        database.addLabel("life", to: "aria2")
        database.addLabel("life", to: "valgrind")

        // MAKR: Test
        XCTAssertEqual(database.formulaes(under: "life").count, 2)
        XCTAssertEqual(database.formulaes(under: "c++").count, 2)

        XCTAssertEqual(database.labels(of: "cmake").count, 1)
        XCTAssertEqual(database.labels(of: "valgrind").count, 2)


        database.removeLabel("c++")
        XCTAssertEqual(database.labels(of: "cmake").count, 0)
        XCTAssertEqual(database.labels(of: "valgrind").count, 1)

        database.removeLabel("life", from: "valgrind")
        XCTAssertEqual(database.labels(of: "valgrind").count, 0)
    }
}
