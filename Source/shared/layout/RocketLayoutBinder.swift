//
//  RocketLayoutBinder.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

class RocketLayoutBinder: NSObject {

    private var metaBinders = [String : RocketLayoutMetaBinder]()
    
    private func binderKey(forLayout layout: RocketLayout, meta: RocketLayoutMeta) -> String {
        return "\(layout.identifier):\(meta.metaType.rawValue)"
    }
    
    private func binder(forLayout layout: RocketLayout, meta: RocketLayoutMeta) -> RocketLayoutMetaBinder {
        let key = binderKey(forLayout: layout, meta: meta)
        var result = metaBinders[key]
        if result == nil {
            result = RocketLayoutMetaBinder()
            metaBinders[key] = result
        }
        return result!
    }
    
    internal func addLayout(_ layoutObject: RocketLayout, layoutProvider: RocketLayoutProvider) {
        binder(forLayout: layoutObject, meta: layoutObject.idealMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.idealMeta, layoutProvider: layoutProvider)
        binder(forLayout: layoutObject, meta: layoutObject.minMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.minMeta, layoutProvider: layoutProvider)
        binder(forLayout: layoutObject, meta: layoutObject.maxMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.maxMeta, layoutProvider: layoutProvider)
    }
    
    internal func cleanUp() {
        for binder in metaBinders.values {
            binder.cleanUp()
        }
        metaBinders.removeAll()
    }
}

