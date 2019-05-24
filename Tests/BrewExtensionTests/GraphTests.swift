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

    func testRemove() {
        var graph = Graph<Int>()

        graph.add(node: 1)
        graph.add(node: 2)
        graph.add(node: 3)
        graph.add(node: 4)

        graph.connect(from: 1, to: 2)
        graph.connect(from: 1, to: 3)
        graph.connect(from: 4, to: 1)

        graph.remove(node: 1)

        XCTAssertTrue(graph.incomings(at: 2)!.isEmpty)
        XCTAssertTrue(graph.incomings(at: 3)!.isEmpty)
        XCTAssertTrue(graph.outcomings(at: 3)!.isEmpty)

        XCTAssertFalse(graph.contains(node: 1))
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

        let zeroInBound = graph.incomings(at: 0)

        XCTAssertNotNil(zeroInBound)
        XCTAssertTrue(zeroInBound!.contains(1))
        XCTAssertTrue(zeroInBound!.contains(2))

        let zeroOutBound = graph.incomings(at: 0)

        XCTAssertNotNil(zeroOutBound)
        XCTAssertTrue(zeroOutBound!.contains(1))
        XCTAssertTrue(zeroOutBound!.contains(2))
    }

    func testSequence() {
        var graph = Graph<Int>()
        graph.add(node: 1)
        graph.add(node: 2)
        graph.add(node: 3)

        var sum = 0

        for item in graph {
            sum += item
        }

        XCTAssertEqual(sum, 6)
    }
}
