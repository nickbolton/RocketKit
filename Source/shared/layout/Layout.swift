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

public struct Layout {
    
    let componentId: String
    var position: CGPoint
    var size: CGSize
    let sublayouts: [Layout]
    private let sublayoutMap: [String : Layout]
        
    var frame: CGRect {
        var subnodeFrame = CGRect.zero
        var adjustedOrigin = position
        
        if adjustedOrigin.x.isInfinite {
            assert(false, "Layout has an invalid x position")
            adjustedOrigin.x = 0
        }
        if adjustedOrigin.y.isInfinite {
            assert(false, "Layout has an invalid y position");
            adjustedOrigin.y = 0
        }
        subnodeFrame.origin = adjustedOrigin
        
        var adjustedSize = size
        if adjustedSize.width.isInfinite {
            assert(false, "Layout has an invalid width")
            adjustedSize.width = 0
        }
        
        if adjustedSize.height.isInfinite {
            assert(false, "Layout has an invalid height")
            adjustedSize.height = 0
        }
        
        subnodeFrame.size = adjustedSize;
        
        return subnodeFrame;
    }
    
    public init(componentId: String, position: CGPoint = .null, size: CGSize = .zero, sublayouts: [Layout] = []) {
    
        #if DEBUG
        for sublayout in sublayouts {
            assert(!sublayout.position.isNull, "Invalid position is not allowed in sublayout.")
        }
        #endif

        if Dimension.isSizeValidForSize(size) {
            self.size = CGSize(width: size.width.halfPointCeilValue, height: size.height.halfPointCeilValue)
        } else {
            assert(false, "layoutSize is invalid and unsafe to provide to Core Animation! Release configurations will force to 0, 0.  Size = \(size)")
            self.size = .zero
        }
        
        if position.isNull {
            self.position = position
        } else {
            self.position = CGPoint(x: position.x.halfPointCeilValue, y: position.y.halfPointCeilValue)
        }
        
        self.componentId = componentId
        self.sublayouts = sublayouts
        
        var map = [String: Layout]()
        for sublayout in sublayouts {
            map[sublayout.componentId] = sublayout
        }
        sublayoutMap = map
    }
}
