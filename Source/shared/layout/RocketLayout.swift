//
//  RocketLayout.swift
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

public class RocketLayout: RocketBaseObject {
    
    let componentIdentifier: String
    let attribute: NSLayoutAttribute
    let relatedComponentIdentifier: String?
    let relatedAttribute: NSLayoutAttribute
    let isDefaultLayout: Bool
    let idealMeta: RocketLayoutMeta
    let minMeta: RocketLayoutMeta
    let maxMeta: RocketLayoutMeta
    let commonAncestorComponentIdentifier: String?
    
    var isSizing: Bool { return attribute == .width || attribute == .height }
    
    var isHorizontal: Bool {
        return RocketLayout.isHorizontal(attribute)
    }
    
    var isVertical: Bool {
        return RocketLayout.isVertical(attribute)
    }

    var isCompletelyDeactivated: Bool {
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
    
    required public init(dictionary: [String: Any], layoutSource: RocketLayoutSource) {
        self.componentIdentifier = dictionary[RocketLayout.componentIdentifierKey] as? String ?? ""
        self.attribute = NSLayoutAttribute(rawValue: dictionary[RocketLayout.attributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.relatedComponentIdentifier = dictionary[RocketLayout.relatedComponentIdentifierKey] as? String
        self.commonAncestorComponentIdentifier = dictionary[RocketLayout.commonAncestorComponentIdentifierKey] as? String
        self.relatedAttribute = NSLayoutAttribute(rawValue: dictionary[RocketLayout.relatedAttributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.isDefaultLayout = dictionary[RocketLayout.defaultLayoutKey] as? Bool ?? false
        self.idealMeta = RocketLayoutMeta(dictionary: dictionary[RocketLayout.idealMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.minMeta = RocketLayoutMeta(dictionary: dictionary[RocketLayout.minMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.maxMeta = RocketLayoutMeta(dictionary: dictionary[RocketLayout.maxMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
}