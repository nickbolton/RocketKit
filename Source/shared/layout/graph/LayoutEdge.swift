//
//  LayoutEdge.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

class LayoutEdge: NSObject, NSCoding {

    private (set) var layoutObjectId: String?
    private (set) var sourceVertex: LayoutVertex?
    private (set) var targetVertex: LayoutVertex?
    
    private let layoutObjectIdKey = "layoutObjectId"
    private let sourceVertexKey = "sourceVertex"
    private let targetVertexKey = "targetVertex"
    
    required init?(coder decoder: NSCoder) {
        super.init()
        self.layoutObjectId = decoder.decodeObject(forKey: layoutObjectIdKey) as? String
        self.sourceVertex = decoder.decodeObject(forKey: sourceVertexKey) as? LayoutVertex
        self.targetVertex = decoder.decodeObject(forKey: targetVertexKey) as? LayoutVertex
    }
    
    required override init() {
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(layoutObjectId, forKey: layoutObjectIdKey)
        coder.encode(sourceVertex, forKey: sourceVertexKey)
        coder.encode(targetVertex, forKey: targetVertexKey)
    }
    
    static func edge(with layoutObjectId: String, sourceVertex: LayoutVertex, targetVertex: LayoutVertex) -> LayoutEdge {
        let result = LayoutEdge()
        result.layoutObjectId = layoutObjectId
        result.sourceVertex = sourceVertex
        result.targetVertex = targetVertex
        return result
    }
    
    override var description: String {
        return "Edge: \(String(describing: sourceVertex)) -> \(String(describing: targetVertex))\n\(layoutObjectId ?? "")"
    }
}
