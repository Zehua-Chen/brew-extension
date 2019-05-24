//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

/// A directed edge graph
public struct Graph<Node: Hashable>: Sequence {

    /// The data of each node
    public struct NodeData {
        /// The node that have incomming connections to "this" node
        var incomings: Set<Node>
        /// The node that have outcoming connections to "this" node
        var outcomings: Set<Node>

        /// Create an empty node data.
        init() {
            self.incomings = Set<Node>()
            self.outcomings = Set<Node>()
        }
    }

    /// Data type of the graph
    public typealias Data = [Node: NodeData]
    /// Data of the graph
    fileprivate var _data: Data

    /// Creates an empty graph
    public init() {
        _data = [:]
    }

    /// Determine if the graph contains the node
    ///
    /// - Parameter node: the node to lookup
    /// - Returns: true if the node exists, false otherwise
    public func contains(node: Node) -> Bool {
        return _data[node] != nil
    }

    /// Add a new node
    ///
    /// - Parameter node: the node to add
    public mutating func add(node: Node) {
        if _data[node] == nil {
            _data[node] = NodeData()
        }
    }

    /// Remove a node
    ///
    /// - Parameter node: the node to remove
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

    /// Add a connection
    ///
    /// - Parameters:
    ///   - source: where the connection starts
    ///   - target: where the connection ends
    public mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outcomings.insert(target)
        _data[target]?.incomings.insert(source)
    }

    /// Get the `NodeData` associated with a node
    ///
    /// - Parameter node: the node to query
    /// - Returns: a `NodeData` instance, if the node exists
    public func data(for node: Node) -> NodeData? {
        return _data[node]
    }

    /// Get the nodes that have incoming connections to a node
    ///
    /// - Parameter node: the node to search incoming nodes for.
    /// - Returns: a optional set of the incoming nodes
    public func incomings(at node: Node) -> Set<Node>? {
        return _data[node]?.incomings
    }

    /// Get the nodes that have outcoming connections to a node
    ///
    /// - Parameter node: the node to search outcoming nodes for.
    /// - Returns: a optional set of the outcoming nodes
    public func outcomings(at node: Node) -> Set<Node>? {
        return _data[node]?.outcomings
    }

    // Sequence Conformance

    /// Iteratoar that go over the nodes of the graph
    public struct Iterator: IteratorProtocol {

        /// Element is the type of the nodes
        public typealias Element = Node
        /// The iterator to the node storage type's iterator
        fileprivate var _iter: Data.Iterator

        /// Create an iterator from an existing node storage type's iterator
        ///
        /// - Parameter iter: the source iterator
        fileprivate init(from iter: Data.Iterator) {
            _iter = iter
        }

        /// Go to the next node
        ///
        /// - Returns: a node if the iterator is not at the end, nil otherwise
        public mutating func next() -> Element? {
            return _iter.next()?.key
        }
    }

    /// Create an iterator
    ///
    /// - Returns: an iterator instance
    public func makeIterator() -> Iterator {
        return Iterator(from: _data.makeIterator())
    }
}
