//
//  GraphTest.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

import XCTest
import BrewExtension

final class GraphTests: XCTestCase {
    
    func testAdd() {
        var graph = Graph<Int>()

        graph.add(node: 0)
        graph.add(node: 2)

        XCTAssertTrue(graph.contains(node: 0))
        XCTAssertTrue(graph.contains(node: 2))
    }

    func testConnect() {
        var graph = Graph<Int>()

        graph.add(node: 0)
        graph.add(node: 1)
        graph.add(node: 2)

        graph.connect(from: 1, to: 0)
        graph.connect(from: 2, to: 0)

        graph.connect(from: 0, to: 1)
        graph.connect(from: 0, to: 2)

        let zeroInBound = graph.inbound(at: 0)

        XCTAssertNotNil(zeroInBound)
        XCTAssertTrue(zeroInBound!.contains(1))
        XCTAssertTrue(zeroInBound!.contains(2))

        let zeroOutBound = graph.inbound(at: 0)

        XCTAssertNotNil(zeroOutBound)
        XCTAssertTrue(zeroOutBound!.contains(1))
        XCTAssertTrue(zeroOutBound!.contains(2))
    }
}
