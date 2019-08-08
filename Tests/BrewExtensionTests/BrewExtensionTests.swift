import XCTest
@testable import BrewExtension

final class BrewExtensionTests: XCTestCase {

    func testUninstallSimple() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: FormulaeInfo())
        graph.insert("0-1", with: FormulaeInfo())
        graph.insert("1-1", with: FormulaeInfo())
        graph.insert("1-2", with: FormulaeInfo())

        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")
        graph.connect(from: "0-1", to: "1-2")

        let brewExt = BrewExtension()
        brewExt.formulaes = graph

        brewExt.uninstall(formulae: "target")
        let names = Set(brewExt.uninstalls)

        XCTAssertEqual(brewExt.uninstalls.count, 2)
        XCTAssertEqual(names.count, 2)

        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("target"))
    }

    func testUninstallComplex() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: FormulaeInfo())
        graph.insert("0-1", with: FormulaeInfo())
        graph.insert("1-0", with: FormulaeInfo())
        graph.insert("1-1", with: FormulaeInfo())
        graph.insert("1-2", with: FormulaeInfo())

        graph.connect(from: "target", to: "1-0")
        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")

        graph.connect(from: "0-1", to: "1-2")
        graph.connect(from: "1-0", to: "1-1")

        let brewExt = BrewExtension()
        brewExt.formulaes = graph

        brewExt.uninstall(formulae: "target")
        let names = Set(brewExt.uninstalls)

        XCTAssertEqual(brewExt.uninstalls.count, 3)
        XCTAssertEqual(names.count, 3)

        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-0"))
        XCTAssertTrue(names.contains("1-1"))
    }

    func testUninstallMultiDepth() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: FormulaeInfo())
        graph.insert("0-1", with: FormulaeInfo())
        graph.insert("1-0", with: FormulaeInfo())
        graph.insert("1-1", with: FormulaeInfo())
        graph.insert("1-2", with: FormulaeInfo())
        graph.insert("2-0", with: FormulaeInfo())
        graph.insert("2-1", with: FormulaeInfo())
        graph.insert("3-0", with: FormulaeInfo())

        graph.connect(from: "target", to: "1-0")
        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")
        graph.connect(from: "0-1", to: "1-2")

        graph.connect(from: "1-0", to: "1-1")
        graph.connect(from: "1-0", to: "2-0")
        graph.connect(from: "1-1", to: "2-1")

        graph.connect(from: "2-1", to: "3-0")

        let brewExt = BrewExtension()
        brewExt.formulaes = graph

        brewExt.uninstall(formulae: "target")
        let names = Set(brewExt.uninstalls)

        XCTAssertEqual(brewExt.uninstalls.count, 6)
        XCTAssertEqual(names.count, 6)

        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-0"))
        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("2-0"))
        XCTAssertTrue(names.contains("2-1"))
        XCTAssertTrue(names.contains("3-0"))
    }
}

