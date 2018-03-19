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
    
    public var layout: Layout? // set by the LayoutEngine
    
    public var layoutSpec: LayoutSpec = AbsoluteLayoutSpec()
    public var layoutProperties = LayoutProperties()
    
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
        
    private let typeKey = "type"
    private let nameKey = "name"
    private let cornerRadiusKey = "cornerRadius"
    private let borderWidthKey = "borderWidth"
    private let clippedKey = "clipped"
    private let rasterizedKey = "rasterized"
    private let alphaKey = "alpha"
    private let borderColorKey = "borderColor"
    private let backgroundColorKey = "backgroundColor"
    private let layoutSpecKey = "layoutSpec"
    private let layoutPropertiesKey = "layoutProperties"
    private let childComponentsKey = "childComponents"
    private let textDescriptorKey = "textDescriptor"
    private let autoConstrainingTextTypeKey = "autoConstrainingTextType"
    private let usePreciseTextAlignmentsKey = "usePreciseTextAlignments"
    
    required public init(dictionary: [String: Any]) {
        self.componentType = ComponentType(rawValue: dictionary[typeKey] as? Int ?? 0) ?? .container
        self.name = dictionary[nameKey] as? String ?? ""
        self.cornerRadius = dictionary[cornerRadiusKey] as? CGFloat ?? 0.0
        self.borderWidth = dictionary[borderWidthKey] as? CGFloat ?? 0.0
        self.isClipped = dictionary[clippedKey] as? Bool ?? false
        self.isRasterized = dictionary[rasterizedKey] as? Bool ?? false
        self.alpha = dictionary[alphaKey] as? CGFloat ?? 0.0
        self.childComponents = RocketComponent.initializeChildComponents(dictionary[childComponentsKey] as? [[String: Any]] ?? [])
        if let dict = dictionary[layoutSpecKey] as? [String: Any] {
            self.layoutSpec = LayoutSpecFactory.buildLayoutSpec(dictionary: dict)
        }
        if let dict = dictionary[layoutPropertiesKey] as? [String: Any] {
            self.layoutProperties = LayoutProperties(dictionary: dict)
        }
        if let colorHexCode = dictionary[borderColorKey] as? String {
            self.borderColor = ColorType(hex: colorHexCode)
        }
        if let colorHexCode = dictionary[backgroundColorKey] as? String {
            self.backgroundColor = ColorType(hex: colorHexCode)
        }
        
        let autoConstrainingTextTypeRawValue = dictionary[autoConstrainingTextTypeKey] as? Int ?? 0
        self.autoConstrainingTextType = AutoConstrainingTextType(rawValue: autoConstrainingTextTypeRawValue)
        
        self.usePreciseTextAlignments = dictionary[usePreciseTextAlignmentsKey] as? Bool ?? false
        
        if let textDescriptorDict = dictionary[textDescriptorKey] as? [String: Any] {
            self.textDescriptor = CompositeTextDescriptor(dictionary: textDescriptorDict)
        }
        
        super.init(dictionary: dictionary)
    }
    
    required public init() {
        super.init()
    }
    
    public override func dictionaryRepresentation() -> [String: Any] {
        var result = super.dictionaryRepresentation()
        result[typeKey] = componentType.rawValue
        result[nameKey] = name
        result[cornerRadiusKey] = cornerRadius
        result[borderWidthKey] = borderWidth
        result[clippedKey] = isClipped
        result[rasterizedKey] = isRasterized
        result[alphaKey] = alpha
        result[layoutSpecKey] = layoutSpec.dictionaryRepresentation()
        result[layoutPropertiesKey] = layoutProperties.dictionaryRepresentation()
        result[autoConstrainingTextTypeKey] = autoConstrainingTextType.rawValue
        result[usePreciseTextAlignmentsKey] = usePreciseTextAlignments
        result[textDescriptorKey] = textDescriptor?.dictionaryRepresentation()
        if let color = borderColor {
            result[borderColorKey] = color.hexcode
        }
        if let color = backgroundColor {
            result[backgroundColorKey] = color.hexcode
        }
        var childrenArray = [[String: Any]]()
        for child in childComponents {
            childrenArray.append(child.dictionaryRepresentation())
        }
        result[childComponentsKey] = childrenArray
        return result
    }
    
    private static func initializeChildComponents(_ components: [[String: Any]]) -> [RocketComponent] {
        var result = [RocketComponent]()
        for dict in components {
            result.append(RocketComponent(dictionary: dict))
        }
        return result
    }
    
    // MARK: Layout
    
    private let lock = DispatchSemaphore(value: 1)
    private var lockingThread: Thread?
    
    func blocking<T>(_ block: ()->T) -> T {
        if Thread.current != lockingThread {
            lock.wait()
            lockingThread = Thread.current
            defer { lock.signal() }
        }
        return block()
    }
    
    private var _isLayoutTransitionInvalid = false
    var isLayoutTransitionInvalid: Bool {
        get { return blocking { return _isLayoutTransitionInvalid } }
        set { blocking { _isLayoutTransitionInvalid = newValue } }
    }
    
    private var _layoutVersion = 0
    var layoutVersion: Int {
        get { return blocking { return _layoutVersion } }
        set { blocking { _layoutVersion = newValue } }
    }

    private var _calculatedLayout = CalculatedLayout()
    var calculatedLayout: CalculatedLayout {
        get { return blocking { return _calculatedLayout } }
        set { blocking { _calculatedLayout = newValue } }
    }
    
    private var _pendingLayout = CalculatedLayout()
    var pendingLayout: CalculatedLayout {
        get { return blocking { return _pendingLayout } }
        set { blocking { _pendingLayout = newValue } }
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

