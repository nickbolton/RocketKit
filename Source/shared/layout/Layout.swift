//
//  Layout.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public class Layout: BaseObject {
    
    public var componentIdentifier = ""
    public var attribute = NSLayoutAttribute.notAnAttribute
    public var relatedComponentIdentifier: String? = nil
    public var relatedAttribute = NSLayoutAttribute.notAnAttribute
    public var isDefaultLayout = false
    public var idealMeta = LayoutMeta()
    public var minMeta = LayoutMeta()
    public var maxMeta = LayoutMeta()
    public var commonAncestorComponentIdentifier: String? = nil
    
    public var isSizing: Bool { return attribute == .width || attribute == .height }
    
    public var isHorizontal: Bool {
        return Layout.isHorizontal(attribute)
    }
    
    public var isVertical: Bool {
        return Layout.isVertical(attribute)
    }

    public var isCompletelyDeactivated: Bool {
        return !idealMeta.isActive && !minMeta.isActive && !maxMeta.isActive
    }

    static func isHorizontal(_ attribute: NSLayoutAttribute) -> Bool {
        switch (attribute) {
        case .width, .left, .right, .centerX, .leading, .trailing:
            return true
        default:
            break
        }
        return false
    }
    
    static func isVertical(_ attribute: NSLayoutAttribute) -> Bool {
        return !isHorizontal(attribute)
    }
    
    private static let componentIdentifierKey = "componentIdentifier"
    private static let attributeKey = "attribute"
    private static let relatedComponentIdentifierKey = "relatedComponentIdentifier"
    private static let commonAncestorComponentIdentifierKey = "commonAncestorComponentIdentifier"
    private static let relatedAttributeKey = "relatedAttribute"
    private static let defaultLayoutKey = "defaultLayout"
    private static let idealMetaKey = "idealMeta"
    private static let minMetaKey = "minMeta"
    private static let maxMetaKey = "maxMeta"

    required public override init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.componentIdentifier = dictionary[Layout.componentIdentifierKey] as? String ?? ""
        self.attribute = NSLayoutAttribute(rawValue: dictionary[Layout.attributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.relatedComponentIdentifier = dictionary[Layout.relatedComponentIdentifierKey] as? String
        self.commonAncestorComponentIdentifier = dictionary[Layout.commonAncestorComponentIdentifierKey] as? String
        self.relatedAttribute = NSLayoutAttribute(rawValue: dictionary[Layout.relatedAttributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.isDefaultLayout = dictionary[Layout.defaultLayoutKey] as? Bool ?? false
        self.idealMeta = LayoutMeta(dictionary: dictionary[Layout.idealMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.minMeta = LayoutMeta(dictionary: dictionary[Layout.minMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.maxMeta = LayoutMeta(dictionary: dictionary[Layout.maxMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
    
    required public override init() {
        super.init()
    }
    
    convenience public init(component: RocketComponent, attribute: NSLayoutAttribute, relatedComponent: RocketComponent? = nil, relatedAttribute: NSLayoutAttribute = .notAnAttribute, idealMeta: LayoutMeta = LayoutMeta()) {
        self.init()
        self.componentIdentifier = component.identifier
        self.attribute = attribute
        self.relatedComponentIdentifier = relatedComponent?.identifier
        self.relatedAttribute = relatedAttribute
        self.idealMeta = idealMeta
        self.commonAncestorComponentIdentifier = relatedComponent != nil ? component.commonAncestor(with: relatedComponent!)?.identifier : component.identifier
    }
}

// MARK: Convenience factory methods

public extension Layout {
    public static func expand(_ component: RocketComponent, to relatedComponent: RocketComponent) -> [Layout] {
        let topLayout = align(component, to: relatedComponent, attribute: .top)
        let bottomLayout = align(component, to: relatedComponent, attribute: .bottom)
        let leftLayout = align(component, to: relatedComponent, attribute: .left)
        let rightLayout = align(component, to: relatedComponent, attribute: .right)
        return [topLayout, bottomLayout, leftLayout, rightLayout]
    }
        
    public static func align(_ component: RocketComponent, to relatedComponent: RocketComponent, attribute: NSLayoutAttribute, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> Layout {
        let meta = LayoutMeta(multipler: multiplier, constant: constant)
        return Layout(component: component, attribute: attribute, relatedComponent: relatedComponent, relatedAttribute: attribute, idealMeta: meta)
    }
    
    public static func align(_ component: RocketComponent, attribute: NSLayoutAttribute, to relatedComponent: RocketComponent, relatedAttribute: NSLayoutAttribute, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> Layout {
        let meta = LayoutMeta(multipler: multiplier, constant: constant)
        return Layout(component: component, attribute: attribute, relatedComponent: relatedComponent, relatedAttribute: relatedAttribute, idealMeta: meta)
    }
    
    public static func size(_ component: RocketComponent, attribute: NSLayoutAttribute, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> Layout {
        assert(attribute == .width || attribute == .height, "only .width and .height attributes are supported")
        let meta = LayoutMeta(multipler: multiplier, constant: constant)
        return Layout(component: component, attribute: attribute, idealMeta: meta)
    }
}
