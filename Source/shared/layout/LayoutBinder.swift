//
//  LayoutBinder.swift
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

class LayoutBinder: NSObject {

//    private var metaBinders = [String : LayoutMetaBinder]()
//
//    private func binderKey(forLayout layout: Layout, meta: LayoutMeta) -> String {
//        return "\(layout.identifier):\(meta.metaType.rawValue)"
//    }
//
//    internal func binder(forLayout layout: Layout, meta: LayoutMeta) -> LayoutMetaBinder {
//        let key = binderKey(forLayout: layout, meta: meta)
//        var result = metaBinders[key]
//        if result == nil {
//            result = LayoutMetaBinder()
//            metaBinders[key] = result
//        }
//        return result!
//    }
    
    internal func addLayout(_ layoutObject: Layout, layoutProvider: LayoutProvider) {
//        binder(forLayout: layoutObject, meta: layoutObject.idealMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.idealMeta, layoutProvider: layoutProvider)
//        binder(forLayout: layoutObject, meta: layoutObject.minMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.minMeta, layoutProvider: layoutProvider)
//        binder(forLayout: layoutObject, meta: layoutObject.maxMeta).createConstraintIfNecessary(with: layoutObject, meta: layoutObject.maxMeta, layoutProvider: layoutProvider)
    }

    internal func updateLayout(_ layoutObject: Layout, layoutProvider: LayoutProvider) {
//        updateLayout(layoutObject, meta: layoutObject.idealMeta, layoutProvider: layoutProvider)
//        updateLayout(layoutObject, meta: layoutObject.minMeta, layoutProvider: layoutProvider)
//        updateLayout(layoutObject, meta: layoutObject.maxMeta, layoutProvider: layoutProvider)
    }
    
//    private func updateLayout(_ layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
//        let layoutBinder = binder(forLayout: layoutObject, meta: meta)
//        if layoutBinder.constraint == nil {
//            layoutBinder.createConstraintIfNecessary(with: layoutObject, meta: meta, layoutProvider: layoutProvider)
//        } else {
//            layoutBinder.updateConstraint(with: meta)
//        }
//    }

    internal func cleanUp() {
//        for binder in metaBinders.values {
//            binder.cleanUp()
//        }
//        metaBinders.removeAll()
    }
}

