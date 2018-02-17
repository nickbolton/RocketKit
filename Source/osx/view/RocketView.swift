//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Cocoa

public class RocketView: NSView, ComponentView {
    public var contentView: RocketBaseView { return self }
    public var view: RocketBaseView { return self }
    public var isRootView: Bool = false
    var textView: TextHavingView?

    public var layoutProvider: LayoutProvider? { didSet { setupViewIfNecessary() } }
    public var component: RocketComponent? { didSet { setupViewIfNecessary() } }
    
    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        setupViewIfNecessary()
    }

    public override var isFlipped: Bool { return true }

    private let binder = ComponentViewBinder()
    
    deinit {
        binder.cleanUp(for: self, component: component, layoutProvider: layoutProvider)
    }
    
    public func applyComponentProperties() {
        guard let component = component else { return }
        wantsLayer = true
        layer?.masksToBounds = component.isClipped
        alphaValue = component.alpha
        layer?.borderWidth = component.borderWidth
        layer?.cornerRadius = component.cornerRadius
        layer?.borderColor = component.borderColor?.cgColor
        layer?.backgroundColor = component.backgroundColor?.cgColor
        applyTextProperties()
    }
    
    public func applyTextProperties() {
        cleanUpTextView()
        setUpTextViewIfNecessary()
    }
    
    private func cleanUpTextView() {
        textView?.view.removeFromSuperview()
        textView = nil
    }
    
    private func setUpTextViewIfNecessary() {
        guard let textDescriptor = component?.textDescriptor, textDescriptor.text != "" else { return }
        textView = ViewFactory().buildTextView(with: textDescriptor)
        textView?.textDescriptor = textDescriptor
        addSubview(textView!.view)
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
        needsLayout = true
    }
    
    // MARK: Layout
    
    override public func layout() {
        guard let component = component, let layoutProvider = layoutProvider else {
            super.layout()
            return
        }

        binder.applyLayout(component: component, layoutProvider: layoutProvider)
        super.layout()
        layoutTextViewIfNecessary()
    }
    
    private func layoutTextViewIfNecessary() {
        guard var textView = textView else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        guard frame.width > 0.0 && frame.height > 0.0 else { return }
        
        var componentFrame = frame
        
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
