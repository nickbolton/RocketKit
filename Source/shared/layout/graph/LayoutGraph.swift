//
//  LayoutGraph.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

enum LayoutGraphType: Int {
    case siblings
    case full
    case fullWithoutDefaultPositionChecks
    case descendants
}

enum LayoutGraphEngineType: Int {
    case componentBased
    case constraintBased
}

struct LayoutSideMask: OptionSet {
    
    typealias RawValue = Int
    var rawValue: Int = 0
    
    init(rawValue: LayoutSideMask.RawValue) {
        self.rawValue = rawValue
    }
    
    init() { }
    
    mutating func formUnion(_ other: LayoutSideMask) {
        rawValue = rawValue | other.rawValue
    }
    
    mutating func formIntersection(_ other: LayoutSideMask) {
        rawValue = rawValue & other.rawValue
    }
    
    mutating func formSymmetricDifference(_ other: LayoutSideMask) {
        let relCompliment1 = rawValue & ~other.rawValue
        let relCompliment2 = ~rawValue & other.rawValue
        rawValue = relCompliment1 | relCompliment2
    }
    
    static var none = LayoutSideMask(rawValue: 0)
    static var top = LayoutSideMask(rawValue: 1 << 0)
    static var bottom = LayoutSideMask(rawValue: 1 << 1)
    static var left = LayoutSideMask(rawValue: 1 << 2)
    static var right = LayoutSideMask(rawValue: 1 << 3)
    static var all = LayoutSideMask.top.union(.bottom).union(.left).union(.right)
}

struct LayoutFrameEngineResult {
    let endingSiblingDisplacement: CGFloat
    let endingDescendentDisplacement: CGFloat
}

protocol LayoutFrameEngine {
    func calculateCanvasPosition(for graph: LayoutGraph,
                                 at vertex: LayoutVertex,
                                 displacement: CGFloat,
                                 previousVertex: LayoutVertex,
                                 otherEditingComponentIds: Set<String>,
                                 isOnTerminalPath: Bool,
                                 positionStore: LayoutVertexPositionStore,
                                 layoutProvider: LayoutProvider,
                                 endingSiblingDisplacement: CGFloat,
                                 endingDescendentDisplacement: CGFloat,
                                 stop: Bool)
}

class LayoutGraph: NSObject, NSCoding {
    
    private (set) var rootVertex: LayoutVertex
    private (set) var graphType = LayoutGraphType.siblings
    private (set) var engineType = LayoutGraphEngineType.componentBased
    private var frameEngine: LayoutFrameEngine?
    @property (nonatomic, readwrite, copy) NSArray<NSArray<AMLayoutEdge *> *> *allGraphPaths;
    @property (nonatomic, readwrite) NSArray<NSString *> *affectedComponentIds;
    @property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *terminalValues;
    @property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *firstTwoVerticesOnTerminalPath;


    private let rootVertexKey = "rootVertex"
    private let graphTypeKey = "graphType"
    private let engineTypeKey = "engineType"
    private let pathsKey = "paths"

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
        coder.encode(rootVertex, forKey: rootVertexKey)
        coder.encode(graphType, forKey: graphTypeKey)
        coder.encode(engineType, forKey: engineTypeKey)
        coder.encode(allGraphPaths, forKey: pathsKey)
    }
}
