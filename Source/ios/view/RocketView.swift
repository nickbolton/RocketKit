//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import UIKit

public class RocketView: UIView, RocketViewProtocol {

    public var view: RocketBaseView { return self }
    public var layoutProvider: RocketLayoutProvider?
    public var component: RocketComponent?
    public var isRootView: Bool = false
    var label: UILabel?
    
    private let binder = RocketComponentViewBinder()
    
    deinit {
        binder.cleanUp(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    public func applyComponentProperties() {
        guard let component = component else { return }
        clipsToBounds = component.isClipped
        alpha = component.alpha
        layer.borderWidth = component.borderWidth
        layer.cornerRadius = component.cornerRadius
        layer.borderColor = component.borderColor?.cgColor
        backgroundColor = component.backgroundColor
        applyLabelPropertiesIfNeeded()
    }
    
    private func applyLabelPropertiesIfNeeded() {
        cleanUpLabel()
        guard let textDescriptor = component?.textDescriptor else { return }
        setUpLabel(textDescriptor)
    }
    
    private func cleanUpLabel() {
        label?.removeFromSuperview()
        label = nil
    }
    
    private func setUpLabel(_ textDescriptor: RocketTextDescriptor) {
        label = UILabel()
        label?.attributedText = textDescriptor.attributedString
        addSubview(label!)
    }
    
    // MARK: Layout
    
    override public func layoutSubviews() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
        layoutLabelIfNecessary()
    }
    
    private func layoutLabelIfNecessary() {
        guard let label = label else { return }
        guard let textDescriptor = component?.textDescriptor else { return }
        label.frame = labelTextFrameWith(textDescriptor: textDescriptor)
    }
}
