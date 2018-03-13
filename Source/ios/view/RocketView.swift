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
        setupSafeContainerIfNecessary()
        applyTextProperties()
    }
    
    var didIt = false
    
    public func applyTextProperties() {
        cleanUpTextView()
        setUpTextView()
        if !didIt {
            didIt = true
//            doit()
        }
    }
    
    private func setupSafeContainerIfNecessary() {
        guard useSafeArea else { return }
        guard safeTopContraint == nil else { return }
        
//        safeContainer.backgroundColor = UIColor.green
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(safeContainer)
        safeTopContraint = NSLayoutConstraint(item: safeContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        safeBottomContraint = NSLayoutConstraint(item: safeContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        safeLeftContraint = NSLayoutConstraint(item: safeContainer, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        safeRightContraint = NSLayoutConstraint(item: safeContainer, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        
        safeTopContraint?.isActive = true
        safeBottomContraint?.isActive = true
        safeLeftContraint?.isActive = true
        safeRightContraint?.isActive = true
    }
    
    func doit() {
        guard var textView = textView else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        
        if textDescriptor.compositeText == "-Jay Z" {
            print("container frame: \(frame), text frame: \((textView as! UILabel).frame)")
        }
        
        let delay = 1.0
        let delayTime = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.doit()
        }
    }
    
    private func cleanUpTextView() {
        textView?.view.removeFromSuperview()
        textView = nil
    }
    
    private func setUpTextView() {
        guard let textDescriptor = component?.textDescriptor, textDescriptor.compositeText.count > 0 else { return }
        textView = ViewFactory().buildTextView(with: textDescriptor)
        textView?.textDescriptor = textDescriptor
        if useSafeArea {
            safeContainer.addSubview(textView!.view)
        } else {
            addSubview(textView!.view)
        }
    }
    
    open override func safeAreaInsetsDidChange() {
        if #available(iOS 11, *) {
            super.safeAreaInsetsDidChange()
            setupSafeContainerIfNecessary()
            safeTopContraint?.constant = safeAreaInsets.top
            safeBottomContraint?.constant = -safeAreaInsets.bottom
            safeLeftContraint?.constant = safeAreaInsets.left
            safeRightContraint?.constant = -safeAreaInsets.right
            safeContainer.layoutIfNeeded()
        }
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
        
//        print("identifier: \(component.identifier)")
        binder.applyLayout(component: component, layoutProvider: layoutProvider)
        super.layoutSubviews()
        layoutTextViewIfNecessary()
    }
    
    private func layoutTextViewIfNecessary() {
        guard var textView = textView else { return }
        guard let component = component else { return }
        guard let textDescriptor = component.textDescriptor else { return }
        guard frame.width > 0.0 || frame.height > 0.0 else { return }
        
        print("frame: \(frame)")

        let boundBy = CGSize(width: frame.width != 0.0 ? frame.width : CGFloat.greatestFiniteMagnitude, height: frame.height != 0.0 ? frame.height : CGFloat.greatestFiniteMagnitude)
        let textMargins = TextMetricsCache.shared.textMetrics(for: textDescriptor, textType: textDescriptor.targetTextType, boundBy: boundBy).textMargins
        
        var componentFrame = useSafeArea ? safeContainer.frame : frame
        componentFrame.size.width -= textMargins.left + textMargins.right
        
        
//        print("identifier: \(component.identifier)")
        if !component.isTopLevelComponent && component.autoConstrainingTextType.contains(.height) {
            let containerFrame = textDescriptor.containerFrame(for: textDescriptor.targetTextType, boundBy: componentFrame.size, usePreciseTextAlignments: component.usePreciseTextAlignments)
            var heightConstraint = component.layoutObject(with: .height)
            if heightConstraint == nil {
                heightConstraint = component.defaultLayoutObject(with: .height)
            }
            if let heightConstraint = heightConstraint, let constraint = binder.layoutBinder.binder(forLayout: heightConstraint, meta: heightConstraint.idealMeta).constraint, constraint.constant != containerFrame.height {
                constraint.constant = containerFrame.height
            }
            
            componentFrame.size.height = containerFrame.height
        }

        var textFrame = textDescriptor.textFrame(for: textDescriptor.targetTextType, boundBy: CGSize(width: componentFrame.width, height: CGFloat.greatestFiniteMagnitude), usePreciseTextAlignments: component.usePreciseTextAlignments, containerSize: componentFrame.size) 
        textFrame.size.width += textMargins.left + textMargins.right
        textView.textSize = textFrame.size
        textView.view.frame = textFrame
    }
}
