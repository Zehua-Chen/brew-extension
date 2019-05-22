//
//  Graph.swift
//  Brew
//
//  Created by Zehua Chen on 5/21/19.
//

public struct Graph<Node: Hashable> {

    fileprivate struct NodeData {
        var inbounds: Set<Node>
        var outbounds: Set<Node>

        init() {
            self.inbounds = Set<Node>()
            self.outbounds = Set<Node>()
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

    public mutating func remove(node: Node) {
        guard let nodeData = _data[node] else { return }

        for inbound in nodeData.inbounds {
            _data[inbound]!.outbounds.remove(node)
        }

        for outbound in nodeData.outbounds {
            _data[outbound]!.inbounds.remove(node)
        }
        
        _data.removeValue(forKey: node)
    }

    public mutating func connect(from source: Node, to target: Node) {
        _data[source]?.outbounds.insert(target)
        _data[target]?.inbounds.insert(source)
    }

    public func inbound(at node: Node) -> Set<Node>? {
        return _data[node]?.inbounds
    }

    public func outbound(at node: Node) -> Set<Node>? {
        return _data[node]?.outbounds
    }
}
