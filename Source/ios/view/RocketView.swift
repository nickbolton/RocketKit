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
    public var isRootView: Bool = false
    var textView: TextHavingView?
    
    public var layoutProvider: LayoutProvider? { didSet { setupViewIfNecessary() } }
    public var component: RocketComponent? { didSet { setupViewIfNecessary() } }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupViewIfNecessary()
    }
    
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
        cleanUpTextView()
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
    
    private func cleanUpTextView() {
        textView?.view.removeFromSuperview()
        textView = nil
    }
    
    private func setUpTextView(_ textDescriptor: TextDescriptor) {
        guard let textDescriptor = component?.textDescriptor, textDescriptor.text != "" else { return }
        textView = ViewFactory().buildTextView(with: textDescriptor)
        textView?.textDescriptor = textDescriptor
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
    
    private func setupViewIfNecessary() {
        guard let component = component else { return }
        guard let layoutProvider = layoutProvider else { return }
        guard superview != nil else { return }
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    // MARK: Helpers
    
    public func updateView() {
        binder.updateView(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    public func updateText() {
        applyTextProperties()
        setNeedsLayout()
    }

    // MARK: Layout
    
    override public func layoutSubviews() {
        guard let component = component, let layoutProvider = layoutProvider else {
            super.layoutSubviews()
            return
        }
        
        binder.applyLayout(component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
        layoutTextViewIfNecessary()
    }
    
    private func layoutTextViewIfNecessary() {
        guard var textView = textView else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        guard frame.width > 0.0 && frame.height > 0.0 else { return }

        let sideMargins = TextMetricsCache.shared.textMargins(for: textDescriptor, textType: textDescriptor.targetTextType)
        
        var componentFrame = useSafeArea ? safeContainer.frame : frame
        componentFrame.size.width -= sideMargins.left + sideMargins.right
        
        if !component.isTopLevelComponent && component.autoConstrainingTextType.contains(.height) {
            if let containerFrame = component.textDescriptor?.containerFrame(textType: textDescriptor.targetTextType, boundBy: CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude), usePreciseTextAlignments: component.usePreciseTextAlignments) {
                
                if let heightConstraint = component.layoutObject(with: .height) {
                    binder.layoutBinder.binder(forLayout: heightConstraint, meta: heightConstraint.idealMeta).constraint?.constant = containerFrame.height
                } else if let heightConstraint = component.defaultLayoutObject(with: .height) {
                    binder.layoutBinder.binder(forLayout: heightConstraint, meta: heightConstraint.idealMeta).constraint?.constant = containerFrame.height
                }
                
                componentFrame.size.height = containerFrame.height
            }
        }

        let textFrame = TextDescriptor.textFrame(for: component, text: textDescriptor.text, textType: textDescriptor.targetTextType, containerSize: componentFrame.size)
        textView.textSize = textFrame.size
        textView.view.frame = textFrame
    }
}
