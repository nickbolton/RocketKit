//
//  ComponentViewBinder.swift
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

class ComponentViewBinder: NSObject {
    
    private var isSetup = false
    private let viewFactory = ViewFactory()
    private let layoutBinder = LayoutBinder()
    
    internal func buildViewIfNecessary(for rocketView: ComponentView, component: RocketComponent?, layoutProvider: LayoutProvider?) {
        guard !isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        isSetup = true
        let view = rocketView.view
        view.translatesAutoresizingMaskIntoConstraints = rocketView.isRootView
        layoutProvider.registerView(rocketView, for: component)
        rocketView.applyComponentProperties()
        applyLayout(component: component, layoutProvider: layoutProvider)
        for child in component.childComponents {
            var childView = viewFactory.buildView(with: child)
            childView.layoutProvider = layoutProvider
            view.addSubview(childView.view)
            #if os(iOS)
                childView.view.setNeedsLayout()
            #endif
        }
    }
    
    internal func cleanUp(for view: ComponentView, component: RocketComponent?, layoutProvider: LayoutProvider?) {
        guard isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        layoutProvider.unregisterView(view, for: component)
        isSetup = false
    }
    
    private func applyLayout(component: RocketComponent, layoutProvider: LayoutProvider) {
        for layoutObject in component.allLayoutObjects {
            layoutBinder.addLayout(layoutObject, layoutProvider: layoutProvider)
        }
    }
}
