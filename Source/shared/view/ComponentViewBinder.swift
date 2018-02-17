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
        let contentView = rocketView.contentView
        for child in component.childComponents {
            let childView = viewFactory.buildView(with: child)
            childView.layoutProvider = layoutProvider
            contentView.addSubview(childView.view)
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
    
    internal func updateView(for rocketView: ComponentView, component: RocketComponent?, layoutProvider: LayoutProvider?) {
        guard isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        rocketView.applyComponentProperties()
        for layoutObject in component.allLayoutObjects {
            layoutBinder.cleanUp()
            layoutBinder.addLayout(layoutObject, layoutProvider: layoutProvider)
        }
    }
    
    func updateText(for rocketView: ComponentView, component: RocketComponent?, layoutProvider: LayoutProvider?) {
        guard isSetup, let component = component, let layoutProvider = layoutProvider else { return }
        rocketView.applyTextProperties()
        if component.autoConstrainingTextType.contains(.height) {
            if let heightConstraint = component.layoutObject(with: .height) ?? component.defaultLayoutObject(with: .height) {
                layoutBinder.updateLayout(heightConstraint, layoutProvider: layoutProvider)
            }
        }
    }
    
    internal func applyLayout(component: RocketComponent, layoutProvider: LayoutProvider) {
        layoutBinder.cleanUp()
        for layoutObject in component.allLayoutObjects {
            layoutBinder.addLayout(layoutObject, layoutProvider: layoutProvider)
        }
    }
}
