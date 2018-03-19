//
//  LayoutSpec.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

public enum LayoutSpecType {
    case absolute
    case stack
}

let specTypeKey = "specType"

public protocol LayoutSpec {
    var specType: LayoutSpecType { get }
    func layoutThatFits(_ component: RocketComponent, in constrainedSize: SizeRange) -> Layout
    init(dictionary: [String: Any])
    func dictionaryRepresentation() -> [String: Any]
}

public struct LayoutSpecFactory {
    
    static public func buildLayoutSpec(dictionary: [String: Any]) -> LayoutSpec {
        if let type = dictionary[specTypeKey] as? LayoutSpecType {
            return buildLayoutSpec(type, dictionary: dictionary)
        }
        return buildLayoutSpec(.absolute)
    }
    
    static public func buildLayoutSpec(_ type: LayoutSpecType, dictionary: [String: Any] = [:]) -> LayoutSpec {
        switch type {
        case .absolute:
            return AbsoluteLayoutSpec(dictionary: dictionary)
        case .stack:
            return StackLayoutSpec(dictionary: dictionary)
        }
    }
}
