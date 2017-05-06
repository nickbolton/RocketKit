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
    import AppKit
#endif

class ComponentViewBinder: NSObject {
    
    private var isSetup = false
    private let viewFactory = ViewFactory()
    private let layoutBinder = LayoutBinder()
    
    internal func buildViewIfNecessary(for rocketView: RocketViewProtocol, component: Component?, layoutProvider: LayoutProvider?) {
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
            childView.view.setNeedsLayout()
        }
    }
    
    internal func cleanUp(for view: RocketViewProtocol, component: Component?, layoutProvider: LayoutProvider?) {
        guard isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        layoutProvider.unregisterView(view, for: component)
    }
    
    private func applyLayout(component: Component, layoutProvider: LayoutProvider) {
        for layoutObject in component.allLayoutObjects {
            layoutBinder.addLayout(layoutObject, layoutProvider: layoutProvider)
        }
    }
}
