//
//  RocketComponentViewBinder.swift
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

class RocketComponentViewBinder: NSObject {
    
    private var isSetup = false
    private let viewFactory = RocketViewFactory()
    private let layoutBinder = RocketLayoutBinder()
    
    internal func buildViewIfNecessary(for rocketView: RocketViewProtocol, component: RocketComponent?, layoutProvider: RocketLayoutProvider?) {
        guard !isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        isSetup = true
        let view = rocketView.view
        view.translatesAutoresizingMaskIntoConstraints = rocketView.isRootView
        layoutProvider.registerView(rocketView, for: component)
        rocketView.applyComponentProperties()
        applyLayout(component: component, layoutProvider: layoutProvider)
        for child in component.childComponents {
            let childView = viewFactory.buildView(with: child)
            childView.layoutProvider = layoutProvider
            view.addSubview(childView.view)
            #if os(iOS)
                childView.view.setNeedsLayout()
            #endif
        }
    }
    
    internal func cleanUp(for view: RocketViewProtocol, component: RocketComponent?, layoutProvider: RocketLayoutProvider?) {
        guard isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        layoutProvider.unregisterView(view, for: component)
        isSetup = false
    }
    
    private func applyLayout(component: RocketComponent, layoutProvider: RocketLayoutProvider) {
        for layoutObject in component.allLayoutObjects {
            layoutBinder.addLayout(layoutObject, layoutProvider: layoutProvider)
        }
    }
}
