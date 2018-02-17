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
    public var contentView: RocketBaseView {
        return useSafeArea ? safeContainer : self
    }
    public var layoutProvider: LayoutProvider?
    public var component: RocketComponent?
    public var isRootView: Bool = false
    var textView: TextHavingView?
    
    public let safeContainer = UIView()
    
    private var safeTopContraint: NSLayoutConstraint?
    private var safeBottomContraint: NSLayoutConstraint?
    private var safeLeftContraint: NSLayoutConstraint?
    private var safeRightContraint: NSLayoutConstraint?
    
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
        applyTextProperties()
    }
    
    public func applyTextProperties() {
        cleanUpLabel()
        guard let textDescriptor = component?.textDescriptor else { return }
        setupSafeContainerIfNecessary()
        setUpTextView(textDescriptor)
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
        textView?.view.removeFromSuperview()
        textView = nil
    }
    
    private func setUpTextView(_ textDescriptor: TextDescriptor) {
        textView = ViewFactory().buildTextView(with: textDescriptor)
        textView?.attributedString = textDescriptor.attributedString
        if useSafeArea {
            safeContainer.addSubview(textView!.view)
        } else {
            addSubview(textView!.view)
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
    
    // MARK: Helpers
    
    public func updateView() {
        binder.updateView(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    public func updateText(animationDuration: TimeInterval = 0.0) {
        applyTextProperties()
        binder.updateText(for: self, component: component, layoutProvider: layoutProvider, animationDuration: animationDuration)
    }

    // MARK: Layout
    
    override public func layoutSubviews() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
        layoutLabelIfNecessary()
    }
    
    private func layoutLabelIfNecessary() {
        guard var textView = textView else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        var componentFrame = useSafeArea ? safeContainer.frame : frame
        
        if !component.isTopLevelComponent && component.autoConstrainingTextType.contains(.height) {
            componentFrame.size.height = component.textHeightConstrainedByWidth
        }
        
        let labelFrame = TextDescriptor.textFrame(for: component, text: textDescriptor.text, textType: component.textDescriptor?.targetTextType ?? .label, containerSize: componentFrame.size)
        textView.textSize = labelFrame.size
        textView.view.frame = labelFrame
        
        print("frame: \(labelFrame)")
    }
}
