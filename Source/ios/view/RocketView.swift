//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import UIKit

public typealias BaseView = UIView

class RocketView: UIView, RocketViewProtocol {

    var view: BaseView { return self }
    var layoutProvider: LayoutProvider?
    var component: Component?
    var isRootView: Bool = false
    
    private let binder = ComponentViewBinder()
    
    deinit {
        binder.cleanUp(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    override func layoutSubviews() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
    }
    
    func applyComponentProperties() {
        guard let component = component else { return }
        clipsToBounds = component.isClipped
        alpha = component.alpha;
        layer.borderWidth = component.borderWidth;
        layer.cornerRadius = component.cornerRadius;
        layer.borderColor = component.borderColor?.cgColor
        layer.backgroundColor = component.backgroundColor?.cgColor
    }
}
