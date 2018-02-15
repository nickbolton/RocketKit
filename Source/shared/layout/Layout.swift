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
    
    let componentIdentifier: String
    let attribute: NSLayoutAttribute
    let relatedComponentIdentifier: String?
    let relatedAttribute: NSLayoutAttribute
    let isDefaultLayout: Bool
    let idealMeta: LayoutMeta
    let minMeta: LayoutMeta
    let maxMeta: LayoutMeta
    let commonAncestorComponentIdentifier: String?
    let isLinkedToTextSize: Bool
    
    var isSizing: Bool { return attribute == .width || attribute == .height }
    
    var isHorizontal: Bool {
        return Layout.isHorizontal(attribute)
    }
    
    var isVertical: Bool {
        return Layout.isVertical(attribute)
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
    private static let isLinkedToTextSizeKey = "linkedToTextSize"

    required public init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.componentIdentifier = dictionary[Layout.componentIdentifierKey] as? String ?? ""
        self.attribute = NSLayoutAttribute(rawValue: dictionary[Layout.attributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.relatedComponentIdentifier = dictionary[Layout.relatedComponentIdentifierKey] as? String
        self.commonAncestorComponentIdentifier = dictionary[Layout.commonAncestorComponentIdentifierKey] as? String
        self.relatedAttribute = NSLayoutAttribute(rawValue: dictionary[Layout.relatedAttributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.isDefaultLayout = dictionary[Layout.defaultLayoutKey] as? Bool ?? false
        self.idealMeta = LayoutMeta(dictionary: dictionary[Layout.idealMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.minMeta = LayoutMeta(dictionary: dictionary[Layout.minMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.maxMeta = LayoutMeta(dictionary: dictionary[Layout.maxMetaKey] as? [String: Any] ?? [:], layoutSource: layoutSource)
        self.isLinkedToTextSize = dictionary[Layout.isLinkedToTextSizeKey] as? Bool ?? false
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
}
