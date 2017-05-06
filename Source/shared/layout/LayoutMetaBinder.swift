//
//  LayoutMetaBinder.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

class LayoutMetaBinder: NSObject {

    private (set) var constraint: NSLayoutConstraint?
    private (set) var proportionalSpacingView: BaseView?
    private (set) var proportionalConstraint: NSLayoutConstraint?
    private (set) var spacerViewConstraint: NSLayoutConstraint?
    private (set) var spacerRelatedViewConstraint: NSLayoutConstraint?

    internal func cleanUp() {
        constraint?.isActive = false
        proportionalConstraint?.isActive = false
        spacerViewConstraint?.isActive = false
        spacerRelatedViewConstraint?.isActive = false
        proportionalConstraint = nil
        spacerViewConstraint = nil
        spacerRelatedViewConstraint = nil
        proportionalSpacingView?.removeFromSuperview()
        proportionalSpacingView = nil
        constraint = nil
    }
    
    internal func createConstraintIfNecessary(with layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
        
        guard let rocketView = layoutProvider.view(with: layoutObject.componentIdentifier) else { return }
        guard !rocketView.isRootView else { return }
        guard rocketView.view.superview != nil, meta.isActive, constraint == nil else { return }
        guard !layoutObject.isDefaultLayout || isDefaultLayoutNeeded(layoutObject, layoutProvider: layoutProvider) else { return }
        
        let relatedView = layoutProvider.view(with: layoutObject.relatedComponentIdentifier)
        
        let defaultLayoutOk =
            layoutObject.isDefaultLayout &&
                (layoutObject.relatedComponentIdentifier == nil || relatedView?.view.superview != nil);
        
        let regularLayoutOk =
            !layoutObject.isDefaultLayout &&
                (layoutObject.isSizing || layoutObject.relatedComponentIdentifier != nil);
        
        if (defaultLayoutOk || regularLayoutOk) {
            
            buildConstraintsWithLayoutObject(layoutObject, meta: meta, layoutProvider: layoutProvider)
            
            var priority: UILayoutPriority = UILayoutPriorityRequired
            
            switch (meta.layoutState) {
            case .def:
                priority = UILayoutPriorityDefaultHigh - 2
                break;
                
            case .low:
                priority = UILayoutPriorityDefaultHigh - 1
                break;
                
            case .notRequired:
                priority = UILayoutPriorityDefaultHigh
                break;
                
            default:
                priority = UILayoutPriorityRequired
                break;
            }
            
            constraint?.priority = priority
            proportionalConstraint?.priority = priority
            spacerViewConstraint?.priority = priority
            spacerRelatedViewConstraint?.priority = priority
            
            constraint?.isActive = true
            proportionalConstraint?.isActive = true
            spacerViewConstraint?.isActive = true
            spacerRelatedViewConstraint?.isActive = true
        }
    }
    
    private func isDefaultLayoutNeeded(_ layoutObject: Layout, layoutProvider: LayoutProvider) -> Bool {
        
        guard let component = layoutProvider.componentByIdentifier(layoutObject.componentIdentifier) else { return false }
        
        if (layoutObject.isDefaultLayout) {
            
            switch (layoutObject.attribute) {
            case .top:
                return component.needsTopDefaultLayoutObject()
                
            case .left:
                return component.needsLeftDefaultLayoutObject()
                
            case .width:
                return component.needsWidthDefaultLayoutObject()
                
            case .height:
                return component.needsHeightDefaultLayoutObject()
                
            default:
                break;
            }
        }
        
        return false
    }
    
    private func buildConstraintsWithLayoutObject(_ layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
        
        if meta.isProportional {
            buildProportionalConstraintsWithLayoutObject(layoutObject, meta: meta, layoutProvider: layoutProvider)
            return
        }
        
        guard let view = layoutProvider.view(with: layoutObject.componentIdentifier) else { return }
        
        let relatedView = layoutProvider.view(with: layoutObject.relatedComponentIdentifier)
        guard layoutObject.isSizing || relatedView != nil else { return }
        
        var relation = NSLayoutRelation.equal
        
        switch (meta.metaType) {
        case .min:
            relation = .greaterThanOrEqual
            break;
            
        case .max:
            relation = .lessThanOrEqual
            break;
            
        default:
            break;
        }
        
        constraint =
            NSLayoutConstraint(item: view,
                               attribute: layoutObject.attribute,
                               relatedBy: relation,
                               toItem: relatedView,
                               attribute: layoutObject.relatedAttribute,
                               multiplier: 1.0,
                               constant: meta.constant)
    }
    
    private func buildProportionalConstraintsWithLayoutObject(_ layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
        
        if ((layoutObject.attribute == .width && meta.proportionalAttribute == .width) ||
            (layoutObject.attribute == .height && meta.proportionalAttribute == .height)) {
            
            guard let view = layoutProvider.view(with: layoutObject.componentIdentifier) else { return }
            guard let proportionalView = proportionalView(meta: meta, layoutProvider: layoutProvider) else { return }
            
            constraint =
                NSLayoutConstraint(item: view,
                                   attribute: layoutObject.attribute,
                                   relatedBy: .equal,
                                   toItem: proportionalView,
                                   attribute: meta.proportionalAttribute,
                                   multiplier: meta.multiplier,
                                   constant: meta.constant)
            
            return;
        }
        
        if (layoutObject.isHorizontal) {
            buildProportionalVerticalConstraintsWithLayoutObject(layoutObject, meta: meta, layoutProvider: layoutProvider)
        } else {
            buildProportionalHorizontalConstraintsWithLayoutObject(layoutObject, meta: meta, layoutProvider: layoutProvider)
        }
    }
    
    private func buildProportionalVerticalConstraintsWithLayoutObject(_ layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
        
        guard let view = layoutProvider.view(with: layoutObject.componentIdentifier) else { return }
        guard let relatedView = layoutProvider.view(with: layoutObject.relatedComponentIdentifier) else { return }
        guard let proportionalView = proportionalView(meta: meta, layoutProvider: layoutProvider) else { return }
        
        guard let spacingView = buildSpacingViewWithLayoutObject(layoutObject, layoutProvider:layoutProvider) else { return }
        
        let spacingWidthConstrant =
            NSLayoutConstraint(item: spacingView,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 1.0)
        
        let spacingLeftConstrant =
            NSLayoutConstraint(item: spacingView,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: spacingView.superview,
                               attribute: .left,
                               multiplier: 1.0,
                               constant: 0.0)
        
        spacingWidthConstrant.isActive = true;
        spacingLeftConstrant.isActive = true;
        
        let startAttribute = startAttributeForVerticalAttribute(layoutObject: layoutObject, meta: meta)
        let endAttribute: NSLayoutAttribute = startAttribute == .top ? .bottom : .top
        let relationAttribute = NSLayoutAttribute.height;
        
        spacerViewConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: startAttribute,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: layoutObject.attribute,
                               multiplier: 1.0,
                               constant: 0.0)
        
        spacerRelatedViewConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: endAttribute,
                               relatedBy: .equal,
                               toItem: relatedView,
                               attribute: layoutObject.relatedAttribute,
                               multiplier: 1.0,
                               constant: 0.0)
        
        proportionalConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: relationAttribute,
                               relatedBy: .equal,
                               toItem: proportionalView,
                               attribute: relationAttribute,
                               multiplier: abs(meta.multiplier),
                               constant: meta.constant)
        
        proportionalSpacingView = spacingView;
    }
    
    private func buildProportionalHorizontalConstraintsWithLayoutObject(_ layoutObject: Layout, meta: LayoutMeta, layoutProvider: LayoutProvider) {
        guard let view = layoutProvider.view(with: layoutObject.componentIdentifier) else { return }
        guard let relatedView = layoutProvider.view(with: layoutObject.relatedComponentIdentifier) else { return }
        guard let proportionalView = proportionalView(meta: meta, layoutProvider: layoutProvider) else { return }
        
        guard let spacingView = buildSpacingViewWithLayoutObject(layoutObject, layoutProvider:layoutProvider) else { return }
        
        let spacingHeightConstrant =
            NSLayoutConstraint(item: spacingView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 1.0)
        
        let spacingTopConstrant =
            NSLayoutConstraint(item: spacingView,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: spacingView.superview,
                               attribute: .top,
                               multiplier: 1.0,
                               constant: 0.0)
        
        spacingHeightConstrant.isActive = true;
        spacingTopConstrant.isActive = true;
        
        let startAttribute = startAttributeForHorizontalAttribute(layoutObject: layoutObject, meta: meta)
        let endAttribute: NSLayoutAttribute = startAttribute == .left ? .right : .left
        let relationAttribute = NSLayoutAttribute.width;
        
        spacerViewConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: startAttribute,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: layoutObject.attribute,
                               multiplier: 1.0,
                               constant: 0.0)
        
        spacerRelatedViewConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: endAttribute,
                               relatedBy: .equal,
                               toItem: relatedView,
                               attribute: layoutObject.relatedAttribute,
                               multiplier: 1.0,
                               constant: 0.0)
        
        proportionalConstraint =
            NSLayoutConstraint(item: spacingView,
                               attribute: relationAttribute,
                               relatedBy: .equal,
                               toItem: proportionalView,
                               attribute: relationAttribute,
                               multiplier: abs(meta.multiplier),
                               constant: meta.constant)
        
        proportionalSpacingView = spacingView;
    }
    
    private func proportionalComponent(meta: LayoutMeta, layoutProvider: LayoutProvider) -> Component? {
        guard let compositeId = meta.proportionalLayoutObjectIdentifier else { return nil }
        let identifiers = compositeId.components(separatedBy: "|")
        guard identifiers.count == 2 else { return nil }
        return layoutProvider.componentByIdentifier(identifiers.first ?? "")
    }
    
    private func proportionalView(meta: LayoutMeta, layoutProvider: LayoutProvider) -> RocketViewProtocol? {
        guard let component = proportionalComponent(meta: meta, layoutProvider: layoutProvider) else { return nil }
        return layoutProvider.view(with: component.identifier)
    }
    
    private func buildSpacingViewWithLayoutObject(_ layoutObject: Layout, layoutProvider: LayoutProvider) -> BaseView? {
        guard let ancestorView = layoutProvider.view(with: layoutObject.commonAncestorComponentIdentifier) else { return nil }
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        ancestorView.view.addSubview(view)
        return view
    }
    
    private func startAttributeForVerticalAttribute(layoutObject: Layout, meta: LayoutMeta) -> NSLayoutAttribute {
        if (layoutObject.isVertical) {
            if (meta.multiplier >= 0.0) {
                return .bottom;
            } else {
                return .top;
            }
        }
        return .notAnAttribute;
    }
    
    private func startAttributeForHorizontalAttribute(layoutObject: Layout, meta: LayoutMeta) -> NSLayoutAttribute {
        if (layoutObject.isHorizontal) {
            if (meta.multiplier >= 0.0) {
                return .right;
            } else {
                return .left;
            }
        }
        return .notAnAttribute;
    }
}
