//
//  LayoutVertex.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

class LayoutVertex: NSObject, NSCoding {

    private (set) var key = ""
    private (set) var componentId = ""
    private (set) var side = NSLayoutAttribute.notAnAttribute
    private (set) var isRoot = false
    private (set) var isTerminal = false
    private (set) var depth = 0
    private (set) var edges = [LayoutEdge]()
    
    var isHorizontal: Bool { return Layout.isHorizontal(side) }
    
    var minPosition: CGFloat = 0.0
    var maxPosition: CGFloat = 0.0
    var appliedDisplacement: CGFloat = 0.0
    var appliedPosition: CGFloat = 0.0

    private let componentIdKey = "componentId"
    private let sideKey = "side"
    private let isRootKey = "isRoot"
    private let depthKey = "depth"
    private let isTerminalKey = "isTerminal"
    private let edgesKey = "edges"
    private let minPositionKey = "minPosition"
    private let maxPositionKey = "maxPosition"

    required init?(coder decoder: NSCoder) {
        super.init()
        self.componentId = decoder.decodeObject(forKey: componentIdKey) as? String ?? ""
        self.side = decoder.decodeObject(forKey: sideKey) as? NSLayoutAttribute ?? .notAnAttribute
        self.isRoot = decoder.decodeObject(forKey: isRootKey) as? Bool ?? false
        self.depth = decoder.decodeObject(forKey: depthKey) as? Int ?? 0
        self.isTerminal = decoder.decodeObject(forKey: isTerminalKey) as? Bool ?? false
        self.minPosition = decoder.decodeObject(forKey: minPositionKey) as? CGFloat ?? 0.0
        self.maxPosition = decoder.decodeObject(forKey: maxPositionKey) as? CGFloat ?? 0.0
        self.edges = decoder.decodeObject(forKey: edgesKey) as? [LayoutEdge] ?? []
        self.key = LayoutVertex.vertexKey(for: componentId, side: side)
    }
    
    required override init() {
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(componentId, forKey: componentIdKey)
        coder.encode(side, forKey: sideKey)
        coder.encode(isRoot, forKey: isRootKey)
        coder.encode(depth, forKey: depthKey)
        coder.encode(isTerminal, forKey: isTerminalKey)
        coder.encode(minPosition, forKey: minPositionKey)
        coder.encode(maxPosition, forKey: maxPositionKey)
        coder.encode(edges, forKey: edgesKey)
    }
    
    static func vertex(with componentId: String, side: NSLayoutAttribute, isRoot: Bool, isTerminal: Bool, depth: Int) -> LayoutVertex {
        let result = LayoutVertex()
        result.key = vertexKey(for: componentId, side: side)
        result.componentId = componentId
        result.side = side
        result.isRoot = isRoot
        result.depth = depth
        result.isTerminal = isTerminal
        result.maxPosition = CGFloat.greatestFiniteMagnitude
        result.minPosition = -CGFloat.greatestFiniteMagnitude
        return result
    }

    static func vertexKey(for componentId: String, side: NSLayoutAttribute) -> String {
        return "\(componentId)-\(side)"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let that = object as? LayoutVertex {
            return componentId == that.componentId && side == that.side
        }
        return false
    }

    override var hash: Int {
        let prime = 31
        var result = 1
        result = prime * result + componentId.hash
        result = prime * result + self.side.rawValue
        return result;
    }
    
    override var description: String {
        return "Vertex: \(componentId) - \(Layout.label(for: side))\(isRoot ? " root" : "")\(isTerminal ? " terminal" : "")"
    }
}
