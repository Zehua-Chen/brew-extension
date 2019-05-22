import XCTest
@testable import BrewExtension

final class BrewExtensionTests: XCTestCase {

    func testUninstallSingleDepth() {
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
        let names = brewExt.itemsToBeUninstalled(for: "to-be-uninstalled")

        XCTAssertEqual(names.count, 2)
        XCTAssertEqual(names, ["to-be-uninstalled", "llvm"])
    }

    func testUninstallMultipleDepths() {

    }
}
