//
//  RocketComponent.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Foundation

public enum ComponentType: Int {
    case container
}

public struct AutoConstrainingTextType: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let none  = AutoConstrainingTextType(rawValue: 0)
    public static let width = AutoConstrainingTextType(rawValue: 1 << 0)
    public static let height  = AutoConstrainingTextType(rawValue: 1 << 1)
    public static let widthAndHeight: AutoConstrainingTextType = [.width, .height]
}

public class RocketComponent: BaseObject {
    
    var componentType = ComponentType.container
    var name = ""

    public var cornerRadius: CGFloat = 0.0
    public var borderWidth: CGFloat = 0.0
    public var isClipped = false
    public var isRasterized = false
    public var alpha: CGFloat = 1.0
    public var borderColor: ColorType?
    public var backgroundColor: ColorType?
    
    public var textDescriptor: CompositeTextDescriptor?
    public var autoConstrainingTextType = AutoConstrainingTextType.none
    public var usePreciseTextAlignments = false
    
    public var layoutObjects = [Layout]()
    var defaultLayoutObjects = [Layout]()
    var allLayoutObjects: [Layout] {
        var result = [Layout]()
        result.append(contentsOf: defaultLayoutObjects)
        result.append(contentsOf: layoutObjects)
        return result
    }
    
    public var childComponents = [RocketComponent]()
    public var parentComponent: RocketComponent?
    
    public var isTopLevelComponent: Bool { return parentComponent == nil }
    public var topLevelComponent: RocketComponent {
        if let parentComponent = parentComponent {
            return parentComponent.topLevelComponent
        }
        return self
    }
    
    public var isContentConstrainedBySafeArea = false
        
    private static let typeKey = "type"
    private static let nameKey = "name"
    private static let cornerRadiusKey = "cornerRadius"
    private static let borderWidthKey = "borderWidth"
    private static let clippedKey = "clipped"
    private static let rasterizedKey = "rasterized"
    private static let alphaKey = "alpha"
    private static let borderColorKey = "borderColor"
    private static let backgroundColorKey = "backgroundColor"
    private static let borderColorProjectColorIdKey = "borderColorProjectColorID"
    private static let backgroundProjectColorIdKey = "backgroundProjectColorID"
    private static let layoutObjectsKey = "layoutObjects"
    private static let defaultLayoutObjectsKey = "defaultLayoutObjects"
    private static let childComponentsKey = "childComponents"
    private static let textDescriptorKey = "textDescriptor"
    private static let autoConstrainingTextTypeKey = "autoConstrainingTextType"
    private static let usePreciseTextAlignmentsKey = "usePreciseTextAlignments"
    
    required public override init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.componentType = ComponentType(rawValue: dictionary[RocketComponent.typeKey] as? Int ?? 0) ?? .container
        self.name = dictionary[RocketComponent.nameKey] as? String ?? ""
        self.cornerRadius = dictionary[RocketComponent.cornerRadiusKey] as? CGFloat ?? 0.0
        self.borderWidth = dictionary[RocketComponent.borderWidthKey] as? CGFloat ?? 0.0
        self.isClipped = dictionary[RocketComponent.clippedKey] as? Bool ?? false
        self.isRasterized = dictionary[RocketComponent.rasterizedKey] as? Bool ?? false
        self.alpha = dictionary[RocketComponent.alphaKey] as? CGFloat ?? 0.0
        self.childComponents = RocketComponent.initializeChildComponents(dictionary[RocketComponent.childComponentsKey] as? [String: [String: Any]] ?? [:], layoutSource: layoutSource)
        self.layoutObjects = RocketComponent.initializeLayoutObjects(dictionary[RocketComponent.layoutObjectsKey] as? [[String: Any]] ?? [], layoutSource: layoutSource)
        self.defaultLayoutObjects = RocketComponent.initializeLayoutObjects(dictionary[RocketComponent.defaultLayoutObjectsKey] as? [[String: Any]] ?? [], layoutSource: layoutSource)
        self.borderColor = RocketComponent.resolveColor(dict: dictionary, colorKey: RocketComponent.borderColorKey, projectColorKey: RocketComponent.borderColorProjectColorIdKey, layoutSource: layoutSource)
        self.backgroundColor = RocketComponent.resolveColor(dict: dictionary, colorKey: RocketComponent.backgroundColorKey, projectColorKey: RocketComponent.backgroundProjectColorIdKey, layoutSource: layoutSource)
        
        let autoConstrainingTextTypeRawValue = dictionary[RocketComponent.autoConstrainingTextTypeKey] as? Int ?? 0
        self.autoConstrainingTextType = AutoConstrainingTextType(rawValue: autoConstrainingTextTypeRawValue)
        
        self.usePreciseTextAlignments = dictionary[RocketComponent.usePreciseTextAlignmentsKey] as? Bool ?? false
        
        if let textDescriptorDict = dictionary[RocketComponent.textDescriptorKey] as? [String: Any] {
            self.textDescriptor = CompositeTextDescriptor(dictionary: textDescriptorDict)
        }
        
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
    
    required public override init() {
        super.init()
    }
    
    private static func resolveColor(dict: [String: Any], colorKey: String, projectColorKey: String, layoutSource: LayoutSource) -> ColorType? {
        var colorHexCode = dict[colorKey] as? String
        if colorHexCode == nil {
            if  let borderColorProjectColorId = dict[projectColorKey] as? String {
                if let hexCode = layoutSource.projectColor(with: borderColorProjectColorId) {
                    colorHexCode = hexCode
                }
            }
        }
        if colorHexCode != nil {
            return ColorType(hex: colorHexCode!)
        }
        return nil
    }
    
    internal func layoutObject(with attribute: NSLayoutAttribute) -> Layout? {
        for layoutObject in layoutObjects {
            if layoutObject.attribute == attribute {
                return layoutObject;
            }
        }
        
        return nil;
    }

    internal func defaultLayoutObject(with attribute: NSLayoutAttribute) -> Layout? {
        for layoutObject in defaultLayoutObjects {
            if layoutObject.attribute == attribute {
                return layoutObject;
            }
        }
        
        return nil;
    }

    internal func hasLayoutObject(with attribute: NSLayoutAttribute) -> Bool {
        return layoutObject(with: attribute) != nil;
    }

    internal func isConstraintCompletelyDisabledWithAttribute(_ attribute: NSLayoutAttribute) -> Bool {
        guard let layoutObject = self.layoutObject(with: attribute) else { return true }
        return layoutObject.isCompletelyDeactivated
    }
    
    internal func needsTopDefaultLayoutObject() -> Bool {
        let result =
            isConstraintCompletelyDisabledWithAttribute(.top) &&
            isConstraintCompletelyDisabledWithAttribute(.bottom) &&
            isConstraintCompletelyDisabledWithAttribute(.centerY)
        return result;
    }

    internal func needsLeftDefaultLayoutObject() -> Bool {
        let result =
            isConstraintCompletelyDisabledWithAttribute(.left) &&
            isConstraintCompletelyDisabledWithAttribute(.right) &&
            isConstraintCompletelyDisabledWithAttribute(.leading) &&
            isConstraintCompletelyDisabledWithAttribute(.trailing) &&
            isConstraintCompletelyDisabledWithAttribute(.centerX)
        return result
    }

    internal func needsWidthDefaultLayoutObject() -> Bool {
        if !isConstraintCompletelyDisabledWithAttribute(.width) {
            return false
        }
        var positionConstraintCount = 0
        if !isConstraintCompletelyDisabledWithAttribute(.left) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.right) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.leading) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.trailing) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.centerX) {
            positionConstraintCount += 1
        }
        return positionConstraintCount < 2
    }

    internal func needsHeightDefaultLayoutObject() -> Bool {
        if !isConstraintCompletelyDisabledWithAttribute(.height) {
            return false
        }
        var positionConstraintCount = 0
        if !isConstraintCompletelyDisabledWithAttribute(.top) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.bottom) {
            positionConstraintCount += 1
        }
        if !isConstraintCompletelyDisabledWithAttribute(.centerY) {
            positionConstraintCount += 1
        }
        return positionConstraintCount < 2
    }

    private static func initializeLayoutObjects(_ layoutObjectArray: [[String: Any]], layoutSource: LayoutSource) -> [Layout] {
        var result = [Layout]()
        for dict in layoutObjectArray {
            result.append(Layout(dictionary: dict, layoutSource: layoutSource))
        }
        return result
    }
    
    private static func initializeChildComponents(_ components: [String: [String: Any]], layoutSource: LayoutSource) -> [RocketComponent] {
        var result = [RocketComponent]()
        for dict in components.values {
            result.append(RocketComponent(dictionary: dict, layoutSource: layoutSource))
        }
        return result
    }
}

// MARK: Ancestor Utilities

extension RocketComponent {
    
    public func isAncestor(of component: RocketComponent) -> Bool {
        var parentComponent = component.parentComponent
        while parentComponent != nil {
            if parentComponent!.identifier == self.identifier {
                return true
            }
            parentComponent = parentComponent?.parentComponent
        }
        
        return false
    }

    public func commonAncestor(with otherComponent: RocketComponent) -> RocketComponent? {
        
        if otherComponent.isAncestor(of: self) {
            return otherComponent
        } else if isAncestor(of: otherComponent) || identifier == otherComponent.identifier {
            return self
        }
        
        var commonAncestor: RocketComponent? = nil
        var parentComponent = self.parentComponent
        while parentComponent != nil {
            commonAncestor = parentComponent?.commonAncestor(with: otherComponent)
            if commonAncestor != nil {
                return commonAncestor
            }
            parentComponent = parentComponent?.parentComponent
        }
        
        parentComponent = otherComponent.parentComponent
        while parentComponent != nil {
            commonAncestor = parentComponent?.commonAncestor(with: self)
            if commonAncestor != nil {
                return commonAncestor
            }
            parentComponent = parentComponent?.parentComponent
        }
        return nil
    }
}
