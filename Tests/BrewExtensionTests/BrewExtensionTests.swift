import XCTest
@testable import BrewExtension

final class BrewExtensionTests: XCTestCase {

    func testUninstallSimple() {
        var graph = Graph<String>()

        graph.add(node: "to-be-uninstalled")
        graph.add(node: "llvm")
        graph.add(node: "python")
        graph.add(node: "sqlite")

        graph.connect(from: "to-be-uninstalled", to: "llvm")
        graph.connect(from: "to-be-uninstalled", to: "python")
        graph.connect(from: "sqlite", to: "python")

        let brewExt = BrewExtension()
        brewExt.formulaes = graph

        let names = Set(brewExt.itemsToBeUninstalled(for: "to-be-uninstalled"))

        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("llvm"))
        XCTAssertTrue(names.contains("to-be-uninstalled"))
    }

    func testUninstallComplex() {
        var graph = Graph<String>()

        graph.add(node: "to-be-uninstalled")
        graph.add(node: "llvm")
        graph.add(node: "libffi")
        graph.add(node: "python")
        graph.add(node: "opencv")

        graph.connect(from: "to-be-uninstalled", to: "llvm")
        graph.connect(from: "to-be-uninstalled", to: "libffi")
        graph.connect(from: "to-be-uninstalled", to: "python")

        graph.connect(from: "opencv", to: "python")
        graph.connect(from: "llvm", to: "libffi")

        let brewExt = BrewExtension()
        brewExt.formulaes = graph

        let names = Set(brewExt.itemsToBeUninstalled(for: "to-be-uninstalled"))

        XCTAssertEqual(names.count, 3)

        XCTAssertTrue(names.contains("to-be-uninstalled"))
        XCTAssertTrue(names.contains("llvm"))
        XCTAssertTrue(names.contains("libffi"))
    }
}

