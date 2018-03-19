//
//  AbsoluteLayoutSpec.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

/** How much space the spec will take up. */
public enum AbsoluteLayoutSpecSizing {
    /** The spec will take up the maximum size possible. */
    case `default`
    /** Computes a size for the spec that is the union of all childrens' frames. */
    case sizeToFit
}

public class AbsoluteLayoutSpec: NSObject, LayoutSpec {
    
    public let specType: LayoutSpecType = .absolute
    public var sizing = AbsoluteLayoutSpecSizing.default
    
    public required init(dictionary: [String: Any]) {
        
    }
    
    public override init() {
        
    }
    
    public func dictionaryRepresentation() -> [String : Any] {
        return [:]
    }
    
    public func layoutThatFits(_ component: RocketComponent, in constrainedSize: SizeRange) -> Layout {
        
        var size = CGSize(width: Dimension.isPointsValidForSize(constrainedSize.max.width) ? constrainedSize.max.width : dimensionUndefined,
                          height: Dimension.isPointsValidForSize(constrainedSize.max.height) ? constrainedSize.max.height : dimensionUndefined)
        
        let children = component.childComponents
        var sublayouts = [Layout]()
        
        for child in children {
            let layoutPosition = child.layoutProperties.position
            let autoMaxSize = CGSize(width: constrainedSize.max.width  - layoutPosition.x, height: constrainedSize.max.height - layoutPosition.y)
            let autoSizeRange = SizeRange(min: .zero, max: autoMaxSize)
            let childConstraint = child.layoutProperties.size.resolveAutoSize(parentSize: size, autoSizeRange: autoSizeRange)
            var sublayout = child.layoutThatFits(childConstraint, parentSize: size)
            sublayout.position = layoutPosition
            sublayouts.append(sublayout)
        }
        
        if sizing == .sizeToFit || size.width.isNaN {
            size.width = constrainedSize.min.width
            for sublayout in sublayouts {
                size.width = max(size.width, sublayout.position.x + sublayout.size.width)
            }
        }
        
        if sizing == .sizeToFit || size.height.isNaN {
            size.height = constrainedSize.min.height
            for sublayout in sublayouts {
                size.height = max(size.height, sublayout.position.y + sublayout.size.height)
            }
        }
        return Layout(componentId: component.identifier, size: constrainedSize.clamp(to: size), sublayouts: sublayouts)
    }
}
