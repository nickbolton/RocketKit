//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Cocoa

public typealias RocketBaseView = NSView

class RocketView: NSView, RocketViewProtocol {

    var view: RocketBaseView { return self }
    var layoutProvider: RocketLayoutProvider?
    var component: RocketComponent?
    var isRootView: Bool = false
    
    private let binder = RocketComponentViewBinder()
    
    deinit {
        binder.cleanUp(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    override func layout() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layout()
    }
    
    func applyComponentProperties() {
        guard let component = component else { return }
        wantsLayer = true
        layer?.masksToBounds = component.isClipped
        alphaValue = component.alpha
        layer?.borderWidth = component.borderWidth
        layer?.cornerRadius = component.cornerRadius
        layer?.borderColor = component.borderColor?.cgColor
        layer?.backgroundColor = component.backgroundColor?.cgColor
    }
}
