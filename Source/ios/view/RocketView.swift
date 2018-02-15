//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import UIKit

public class RocketView: UIView, ComponentView {

    public var view: RocketBaseView { return self }
    public var layoutProvider: LayoutProvider?
    public var component: RocketComponent?
    public var isRootView: Bool = false
    var label: UILabel?
    
    public let safeContainer = UIView()
    
    private (set) var safeTopContraint: NSLayoutConstraint?
    private (set) var safeBottomContraint: NSLayoutConstraint?
    private (set) var safeLeftContraint: NSLayoutConstraint?
    private (set) var safeRightContraint: NSLayoutConstraint?
    
    private var useSafeArea: Bool { return component?.isContentConstrainedBySafeArea ?? false }

    private let binder = ComponentViewBinder()
    
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
        setupSafeContainerIfNecessary()
        setUpLabel(textDescriptor)
    }
    
    private func setupSafeContainerIfNecessary() {
        guard useSafeArea else { return }
        guard safeTopContraint == nil else { return }
        
//        safeContainer.backgroundColor = UIColor.green
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safeContainer)
        safeTopContraint = NSLayoutConstraint(item: safeContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: safeAreaInsets.top)
        safeBottomContraint = NSLayoutConstraint(item: safeContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -safeAreaInsets.bottom)
        safeLeftContraint = NSLayoutConstraint(item: safeContainer, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: safeAreaInsets.left)
        safeRightContraint = NSLayoutConstraint(item: safeContainer, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -safeAreaInsets.right)
        
        safeTopContraint?.isActive = true
        safeBottomContraint?.isActive = true
        safeLeftContraint?.isActive = true
        safeRightContraint?.isActive = true
    }
    
    private func cleanUpLabel() {
        label?.removeFromSuperview()
        label = nil
    }
    
    private func setUpLabel(_ textDescriptor: TextDescriptor) {
        label = UILabel()
        label?.attributedText = textDescriptor.attributedString
        label?.numberOfLines = 0
        if useSafeArea {
            safeContainer.addSubview(label!)
        } else {
            addSubview(label!)
        }
    }
    
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setupSafeContainerIfNecessary()
        safeTopContraint?.constant = safeAreaInsets.top
        safeBottomContraint?.constant = -safeAreaInsets.bottom
        safeLeftContraint?.constant = safeAreaInsets.left
        safeRightContraint?.constant = -safeAreaInsets.right
        safeContainer.layoutIfNeeded()
    }
    
    // MARK: Layout
    
    override public func layoutSubviews() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
        layoutLabelIfNecessary()
    }
    
    private func layoutLabelIfNecessary() {
        guard let label = label else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        let componentFrame = useSafeArea ? safeContainer.frame : frame
        
        label.frame = TextDescriptor.textFrame(for: component, text: textDescriptor.text, textType: .label, containerSize: componentFrame.size)
    }
}
