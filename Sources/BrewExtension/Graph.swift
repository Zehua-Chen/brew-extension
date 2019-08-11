//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

/// A directed edge graph
public struct Graph<Node: Hashable, Data>: Sequence {

    /// The data of each node
    @usableFromInline
    internal struct _NodeData {
        /// The node that have incomming connections to "this" node
        @usableFromInline
        var incomings = Set<Node>()

        /// The node that have outcoming connections to "this" node
        @usableFromInline
        var outcomings = Set<Node>()

        @usableFromInline
        var data: Data

        /// Create an empty node data.
        @usableFromInline
        init(data: Data) {
            self.data = data
        }
    }
    
    internal enum _GraphKeys: CodingKey {
        case data
    }

    internal typealias _Data = [Node: _NodeData]

    /// Data of the graph
    @usableFromInline
    internal var _data: [Node: _NodeData]

    /// Creates an empty graph
    @inlinable
    public init() {
        _data = [:]
    }

    /// Determine if the graph contains the node
    ///
    /// - Parameter node: the node to lookup
    /// - Returns: true if the node exists, false otherwise
    @inlinable
    public func contains(_ node: Node) -> Bool {
        return _data[node] != nil
    }

    /// Add a new node with associated value
    ///
    /// - Parameters:
    ///   - node: the node to add
    ///   - data: data to be associated with the node
    @inlinable
    public mutating func insert(_ node: Node, with data: Data) {
        if _data[node] == nil {
            _data[node] = _NodeData(data: data)
        }
    }

    /// Remove a node
    ///
    /// - Parameter node: the node to remove
    @inlinable
    public mutating func remove(_ node: Node) {
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
    @inlinable
    public mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outcomings.insert(target)
        _data[target]?.incomings.insert(source)
    }

    /// Get the `NodeData` associated with a node
    ///
    /// - Parameter node: the node to query
    /// - Returns: a `NodeData` instance, if the node exists
    @inlinable
    public func data(for node: Node) -> Data? {
        return _data[node]?.data
    }

    /// Get the nodes that have incoming connections to a node
    ///
    /// - Parameter node: the node to search incoming nodes for.
    /// - Returns: a optional set of the incoming nodes
    @inlinable
    public func incomings(for node: Node) -> Set<Node>? {
        return _data[node]?.incomings
    }

    /// Get the nodes that have outcoming connections to a node
    ///
    /// - Parameter node: the node to search outcoming nodes for.
    /// - Returns: a optional set of the outcoming nodes
    @inlinable
    public func outcomings(for node: Node) -> Set<Node>? {
        return _data[node]?.outcomings
    }

    /// Get or set the associated data with the node
    ///
    /// - Parameter node: the associated node
    @inlinable
    public subscript(node: Node) -> Data? {
        get { return _data[node]?.data }
        set {
            if let value = newValue {
                _data[node]?.data = value
            }
        }
    }

    // Sequence Conformance

    /// Iteratoar that go over the nodes of the graph
    public struct Iterator: IteratorProtocol {

        /// Element is the type of the nodes
        public typealias Element = (node: Node, data: Data)
        /// The iterator to the node storage type's iterator
        @usableFromInline
        internal var _iter: Dictionary<Node, _NodeData>.Iterator

        /// Create an iterator from an existing node storage type's iterator
        ///
        /// - Parameter iter: the source iterator
        @usableFromInline
        internal init(from iter: Dictionary<Node, _NodeData>.Iterator) {
            _iter = iter
        }

        /// Go to the next node
        ///
        /// - Returns: a node if the iterator is not at the end, nil otherwise
        @inlinable
        public mutating func next() -> Element? {
            if let element = _iter.next() {
                return (node: element.key, data: element.value.data)
            }

            return nil
        }
    }

    /// Create an iterator
    ///
    /// - Returns: an iterator instance
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(from: _data.makeIterator())
    }
}

// MARK: Encodable Decodable Conformance

extension Graph._NodeData: Encodable where Node: Encodable, Data: Encodable {}
extension Graph._NodeData: Decodable where Node: Decodable, Data: Decodable {}

extension Graph: Encodable where Node: Encodable, Data: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: _GraphKeys.self)
        try container.encode(_data, forKey: .data)
    }
}

extension Graph: Decodable where Node: Decodable, Data: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: _GraphKeys.self)
        _data = try container.decode(_Data.self, forKey: .data)
    }
}
