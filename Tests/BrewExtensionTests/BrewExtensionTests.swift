import XCTest
@testable import BrewExtension

fileprivate class SimpleDataSource: BrewExtensionDataSource {
    var formulaes: BrewExtension.Formulaes
    var labels: BrewExtension.Labels

    init(formulaes: BrewExtension.Formulaes = .init(), labels: BrewExtension.Labels = .init()) {
        self.formulaes = formulaes
        self.labels = labels
    }

    func flush() throws {}
    func load() throws {}
}

final class BrewExtensionTests: XCTestCase {

    // MARK: Uninstall Without User Package

    func testUninstallSimple() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: .init())
        graph.insert("0-1", with: .init())
        graph.insert("1-1", with: .init())
        graph.insert("1-2", with: .init())

        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")
        graph.connect(from: "0-1", to: "1-2")

        let brewExt = BrewExtension()
        let dataSource = SimpleDataSource(formulaes: graph)
        brewExt.dataSource = dataSource

        let names = Set(brewExt.findFormulaesToUninstall(for: "target"))

        XCTAssertEqual(names.count, 2)

        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("target"))
    }

    func testUninstallComplex() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: .init())
        graph.insert("0-1", with: .init())
        graph.insert("1-0", with: .init())
        graph.insert("1-1", with: .init())
        graph.insert("1-2", with: .init())

        graph.connect(from: "target", to: "1-0")
        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")

        graph.connect(from: "0-1", to: "1-2")
        graph.connect(from: "1-0", to: "1-1")

        let brewExt = BrewExtension()
        let dataSource = SimpleDataSource(formulaes: graph)
        brewExt.dataSource = dataSource

        let names = Set(brewExt.findFormulaesToUninstall(for: "target"))

        XCTAssertEqual(names.count, 3)

        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-0"))
        XCTAssertTrue(names.contains("1-1"))
    }

    func testUninstallMultiDepth() {
        var graph = Graph<String, FormulaeInfo>()

        graph.insert("target", with: .init())
        graph.insert("0-1", with: .init())
        graph.insert("1-0", with: .init())
        graph.insert("1-1", with: .init())
        graph.insert("1-2", with: .init())
        graph.insert("2-0", with: .init())
        graph.insert("2-1", with: .init())
        graph.insert("3-0", with: .init())

        graph.connect(from: "target", to: "1-0")
        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")
        graph.connect(from: "0-1", to: "1-2")

        graph.connect(from: "1-0", to: "1-1")
        graph.connect(from: "1-0", to: "2-0")
        graph.connect(from: "1-1", to: "2-1")

        graph.connect(from: "2-1", to: "3-0")

        let brewExt = BrewExtension()
        let dataSource = SimpleDataSource(formulaes: graph)
        brewExt.dataSource = dataSource

        let names = Set(brewExt.findFormulaesToUninstall(for: "target"))

        XCTAssertEqual(names.count, 6)

        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-0"))
        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("2-0"))
        XCTAssertTrue(names.contains("2-1"))
        XCTAssertTrue(names.contains("3-0"))
    }

    // MARK: Uninstall With User Package

    func testUserPackageUninstall() {
        var graph = Graph<String, FormulaeInfo>()
        // User packages
        graph.insert("target", with: .init(isUserPackage: true))
        graph.insert("0-1", with: .init(isUserPackage: true))
        graph.insert("0-2", with: .init(isUserPackage: true))

        graph.insert("1-0", with: .init())
        graph.insert("1-1", with: .init())
        graph.insert("1-2", with: .init())
        graph.insert("1-3", with: .init())

        graph.insert("2-0", with: .init())
        graph.insert("2-1", with: .init())

        graph.connect(from: "0-1", to: "1-0")
        graph.connect(from: "target", to: "1-1")
        graph.connect(from: "target", to: "1-2")
        graph.connect(from: "0-2", to: "1-3")
        graph.connect(from: "1-1", to: "0-1")

        graph.connect(from: "1-2", to: "0-2")
        graph.connect(from: "1-2", to: "2-0")

        graph.connect(from: "1-3", to: "2-0")
        graph.connect(from: "1-3", to: "2-1")

        graph.connect(from: "2-0", to: "1-0")

        let brewExt = BrewExtension()
        let dataSource = SimpleDataSource(formulaes: graph)
        brewExt.dataSource = dataSource

        let names = brewExt.findFormulaesToUninstall(for: "target")

        XCTAssertEqual(names.count, 3)
        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("1-2"))
    }
}

