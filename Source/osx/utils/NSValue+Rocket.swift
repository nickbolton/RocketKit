//
//  NSValue+Rocket.swift
//  Pods-RocketTestMacObjc
//
//  Created by Nick Bolton on 2/14/18.
//

import Foundation

extension NSValue {
    var uiEdgeInsetsValue: NSEdgeInsets { return edgeInsetsValue }
    convenience init(uiEdgeInsets: NSEdgeInsets) {
        self.init(edgeInsets: uiEdgeInsets)
    }
}
