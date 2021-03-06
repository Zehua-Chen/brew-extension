//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

/// A directed edge graph
internal struct _Graph<Node: Hashable, Data>: Sequence {

    /// The data of each node
    fileprivate struct _NodeData {
        /// The node that have incomming connections to "this" node
        var incomings = Set<Node>()

        /// The node that have outcoming connections to "this" node
        var outcomings = Set<Node>()
        var data: Data

        /// Create an empty node data.
        init(data: Data) {
            self.data = data
        }
    }

    fileprivate typealias _Data = [Node: _NodeData]

    /// Data of the graph
    fileprivate var _data = [Node: _NodeData]()

    /// Determine if the graph contains the node
    ///
    /// - Parameter node: the node to lookup
    /// - Returns: true if the node exists, false otherwise
    internal func contains(_ node: Node) -> Bool {
        return _data[node] != nil
    }

    /// Add a new node with associated value
    ///
    /// - Parameters:
    ///   - node: the node to add
    ///   - data: data to be associated with the node
    internal mutating func insert(_ node: Node, with data: Data) {
        if _data[node] == nil {
            _data[node] = _NodeData(data: data)
        }
    }

    /// Remove a node
    ///
    /// - Parameter node: the node to remove
    internal mutating func remove(_ node: Node) {
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
    internal mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outcomings.insert(target)
        _data[target]?.incomings.insert(source)
    }

    /// Get the `NodeData` associated with a node
    ///
    /// - Parameter node: the node to query
    /// - Returns: a `NodeData` instance, if the node exists
    internal func data(for node: Node) -> Data? {
        return _data[node]?.data
    }

    /// Get the nodes that have incoming connections to a node
    ///
    /// - Parameter node: the node to search incoming nodes for.
    /// - Returns: a optional set of the incoming nodes
    internal func incomings(for node: Node) -> Set<Node>? {
        return _data[node]?.incomings
    }

    /// Get the nodes that have outcoming connections to a node
    ///
    /// - Parameter node: the node to search outcoming nodes for.
    /// - Returns: a optional set of the outcoming nodes
    internal func outcomings(for node: Node) -> Set<Node>? {
        return _data[node]?.outcomings
    }

    /// Get or set the associated data with the node
    ///
    /// - Parameter node: the associated node
    internal subscript(node: Node) -> Data? {
        get { return _data[node]?.data }
        set {
            if let value = newValue {
                _data[node]?.data = value
            }
        }
    }

    // Sequence Conformance

    /// Iteratoar that go over the nodes of the graph
    internal struct Iterator: IteratorProtocol {

        /// Element is the type of the nodes
        internal typealias Element = (node: Node, data: Data)
        /// The iterator to the node storage type's iterator
        fileprivate var _iter: Dictionary<Node, _NodeData>.Iterator

        /// Create an iterator from an existing node storage type's iterator
        ///
        /// - Parameter iter: the source iterator
        fileprivate init(from iter: Dictionary<Node, _NodeData>.Iterator) {
            _iter = iter
        }

        /// Go to the next node
        ///
        /// - Returns: a node if the iterator is not at the end, nil otherwise
        @inlinable
        internal mutating func next() -> Element? {
            if let element = _iter.next() {
                return (node: element.key, data: element.value.data)
            }

            return nil
        }
    }

    /// Create an iterator
    ///
    /// - Returns: an iterator instance
    internal func makeIterator() -> Iterator {
        return Iterator(from: _data.makeIterator())
    }
}
