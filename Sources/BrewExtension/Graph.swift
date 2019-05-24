//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

public struct Graph<Node: Hashable>: Sequence {

    public struct NodeData {
        var incomings: Set<Node>
        var outcomings: Set<Node>

        init() {
            self.incomings = Set<Node>()
            self.outcomings = Set<Node>()
        }
    }

    public typealias Data = [Node: NodeData]

    fileprivate var _data: Data

    public init() {
        _data = [:]
    }

    public func contains(node: Node) -> Bool {
        return _data[node] != nil
    }

    public mutating func add(node: Node) {
        if _data[node] == nil {
            _data[node] = NodeData()
        }
    }

    public mutating func remove(node: Node) {
        guard let nodeData = _data[node] else { return }

        for inbound in nodeData.incomings {
            _data[inbound]!.outcomings.remove(node)
        }

        for outbound in nodeData.outcomings {
            _data[outbound]!.incomings.remove(node)
        }
        
        _data.removeValue(forKey: node)
    }

    public mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outcomings.insert(target)
        _data[target]?.incomings.insert(source)
    }

    public func data(for node: Node) -> NodeData? {
        return _data[node]
    }

    public func incomings(at node: Node) -> Set<Node>? {
        return _data[node]?.incomings
    }

    public func outcomings(at node: Node) -> Set<Node>? {
        return _data[node]?.outcomings
    }

    // Sequence Conformance

    public struct Iterator: IteratorProtocol {

        public typealias Element = Node

        fileprivate var _iter: Data.Iterator

        public init(from iter: Data.Iterator) {
            _iter = iter
        }

        public mutating func next() -> Element? {
            return _iter.next()?.key
        }
    }

    public func makeIterator() -> Iterator {
        return Iterator(from: _data.makeIterator())
    }
}
