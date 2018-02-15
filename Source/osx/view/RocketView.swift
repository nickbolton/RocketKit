//
//  RocketView.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Cocoa

public class RocketView: NSView, ComponentView {

    public var view: RocketBaseView { return self }
    public var layoutProvider: LayoutProvider?
    public var component: RocketComponent?
    public var isRootView: Bool = false
    var label: NSTextField?
    
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
    
    private func setUpLabel(_ textDescriptor: TextDescriptor) {
        label = NSTextField()
        label?.isBezeled = false
        label?.isEditable = false
        label?.maximumNumberOfLines = 0
        label?.backgroundColor = NSColor.clear
        label?.attributedStringValue = textDescriptor.attributedString
        addSubview(label!)
    }
    
    // MARK: Layout
    
    override public func layout() {
        binder.buildViewIfNecessary(for: self, component: component, layoutProvider: layoutProvider)
        super.layout()
        layoutLabelIfNecessary()
    }
    
    private func layoutLabelIfNecessary() {
        guard let label = label else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        label.frame = TextDescriptor.textFrame(for: component, text: textDescriptor.text, textType: .label, containerSize: frame.size)
    }
}
