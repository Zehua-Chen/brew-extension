import XCTest
@testable import BrewExtension

final class FindUninstallablesOperationTests: XCTestCase, FindUninstallablesOperation {

    // MARK: Uninstall Without User Package

    fileprivate func _findUninstallFormulae(for formulae: String, cache: EncodableCache) -> Set<String> {
        return Set(self.findUninstallFormulae(for: "target", cache: cache).lazy.map{ return $0.name })
    }

    func testUninstallSimple() {
        let cache = EncodableCache()

        cache.addFormulae("target")
        cache.addFormulae("0-1")
        cache.addFormulae("1-1")
        cache.addFormulae("1-2")

        cache.addDependency(from: "target", to: "1-1")
        cache.addDependency(from: "target", to: "1-2")
        cache.addDependency(from: "0-1", to: "1-2")

        let names = _findUninstallFormulae(for: "target", cache: cache)

        XCTAssertEqual(names.count, 2)

        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("target"))
    }

    func testUninstallComplex() {
        let cache = EncodableCache()

        cache.addFormulae("target")
        cache.addFormulae("0-1")
        cache.addFormulae("1-0")
        cache.addFormulae("1-1")
        cache.addFormulae("1-2")

        cache.addDependency(from: "target", to: "1-0")
        cache.addDependency(from: "target", to: "1-1")
        cache.addDependency(from: "target", to: "1-2")

        cache.addDependency(from: "0-1", to: "1-2")
        cache.addDependency(from: "1-0", to: "1-1")

        let names = _findUninstallFormulae(for: "target", cache: cache)

        XCTAssertEqual(names.count, 3)

        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-0"))
        XCTAssertTrue(names.contains("1-1"))
    }

    func testUninstallMultiDepth() {
        let cache = EncodableCache()

        cache.addFormulae("target")
        cache.addFormulae("0-1")
        cache.addFormulae("1-0")
        cache.addFormulae("1-1")
        cache.addFormulae("1-2")
        cache.addFormulae("2-0")
        cache.addFormulae("2-1")
        cache.addFormulae("3-0")

        cache.addDependency(from: "target", to: "1-0")
        cache.addDependency(from: "target", to: "1-1")
        cache.addDependency(from: "target", to: "1-2")
        cache.addDependency(from: "0-1", to: "1-2")

        cache.addDependency(from: "1-0", to: "1-1")
        cache.addDependency(from: "1-0", to: "2-0")
        cache.addDependency(from: "1-1", to: "2-1")

        cache.addDependency(from: "2-1", to: "3-0")

        let names = _findUninstallFormulae(for: "target", cache: cache)

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
        let graph = EncodableCache()
        // User packages
        graph.addFormulae("target")
        graph.addFormulae("0-1")
        graph.addFormulae("0-2")

        graph.protectFormulae("target")
        graph.protectFormulae("0-1")
        graph.protectFormulae("0-2")

        graph.addFormulae("1-0")
        graph.addFormulae("1-1")
        graph.addFormulae("1-2")
        graph.addFormulae("1-3")

        graph.addFormulae("2-0")
        graph.addFormulae("2-1")

        graph.addDependency(from: "0-1", to: "1-0")
        graph.addDependency(from: "target", to: "1-1")
        graph.addDependency(from: "target", to: "1-2")
        graph.addDependency(from: "0-2", to: "1-3")
        graph.addDependency(from: "1-1", to: "0-1")

        graph.addDependency(from: "1-2", to: "0-2")
        graph.addDependency(from: "1-2", to: "2-0")

        graph.addDependency(from: "1-3", to: "2-0")
        graph.addDependency(from: "1-3", to: "2-1")

        graph.addDependency(from: "2-0", to: "1-0")

        let names = _findUninstallFormulae(for: "target", cache: graph)

        XCTAssertEqual(names.count, 3)
        XCTAssertTrue(names.contains("target"))
        XCTAssertTrue(names.contains("1-1"))
        XCTAssertTrue(names.contains("1-2"))
    }
}
