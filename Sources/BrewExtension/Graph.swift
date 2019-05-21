//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

public struct Graph<Node: Hashable> {

    fileprivate struct NodeData {
        var inbound: Set<Node>
        var outbound: Set<Node>

        init() {
            self.inbound = Set<Node>()
            self.outbound = Set<Node>()
        }
    }

    fileprivate var _data: [Node: NodeData]

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

    public mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outbound.insert(target)
        _data[target]?.inbound.insert(source)
    }

    public func inbound(at node: Node) -> Set<Node>? {
        return _data[node]?.inbound
    }

    public func outbound(at node: Node) -> Set<Node>? {
        return _data[node]?.outbound
    }
}
