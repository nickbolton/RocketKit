//
//  Component.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

public enum ComponentType: Int {
    case container
}

public class Component: BaseObject {
    
    let componentType: ComponentType
    let name: String

    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let isClipped: Bool
    let isRasterized: Bool
    let alpha: CGFloat
    var borderColor: ColorType?
    var backgroundColor: ColorType?
    
    let layoutObjects: [Layout]
    let defaultLayoutObjects: [Layout]
    var allLayoutObjects: [Layout] {
        var result = [Layout]()
        result.append(contentsOf: defaultLayoutObjects)
        result.append(contentsOf: layoutObjects)
        return result
    }
    
    let childComponents: [Component]
    internal (set) var parentComponent: Component?
    
    var isTopLevelComponent: Bool { return parentComponent == nil }
    var topLevelComponent: Component {
        if let parentComponent = parentComponent {
            return parentComponent.topLevelComponent
        }
        return self
    }
    
    var isContainer: Bool { return componentType == .container }
    
    private static let typeKey = "type"
    private static let nameKey = "name"
    private static let cornerRadiusKey = "cornerRadius"
    private static let borderWidthKey = "borderWidth"
    private static let clippedKey = "clipped"
    private static let rasterizedKey = "rasterized"
    private static let alphaKey = "alpha"
    internal static let borderColorKey = "borderColor"
    internal static let backgroundColorKey = "backgroundColor"
    internal static let borderColorProjectColorIdKey = "borderColorProjectColorID"
    internal static let backgroundProjectColorIdKey = "backgroundProjectColorID"
    private static let layoutObjectsKey = "layoutObjects"
    private static let defaultLayoutObjectsKey = "defaultLayoutObjects"
    private static let childComponentsKey = "childComponents"

    required public init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.componentType = ComponentType(rawValue: dictionary[Component.typeKey] as? Int ?? 0) ?? .container
        self.name = dictionary[Component.nameKey] as? String ?? ""
        self.cornerRadius = dictionary[Component.cornerRadiusKey] as? CGFloat ?? 0.0
        self.borderWidth = dictionary[Component.borderWidthKey] as? CGFloat ?? 0.0
        self.isClipped = dictionary[Component.clippedKey] as? Bool ?? false
        self.isRasterized = dictionary[Component.rasterizedKey] as? Bool ?? false
        self.alpha = dictionary[Component.alphaKey] as? CGFloat ?? 0.0
        self.childComponents = Component.initializeChildComponents(dictionary[Component.childComponentsKey] as? [String: [String: Any]] ?? [:], layoutSource: layoutSource)
        self.layoutObjects = Component.initializeLayoutObjects(dictionary[Component.layoutObjectsKey] as? [[String: Any]] ?? [], layoutSource: layoutSource)
        self.defaultLayoutObjects = Component.initializeLayoutObjects(dictionary[Component.defaultLayoutObjectsKey] as? [[String: Any]] ?? [], layoutSource: layoutSource)
        self.borderColor = Component.resolveColor(dict: dictionary, colorKey: Component.borderColorKey, projectColorKey: Component.borderColorProjectColorIdKey, layoutSource: layoutSource)
        self.backgroundColor = Component.resolveColor(dict: dictionary, colorKey: Component.backgroundColorKey, projectColorKey: Component.backgroundProjectColorIdKey, layoutSource: layoutSource)
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
    
    private static func resolveColor(dict: [String: Any], colorKey: String, projectColorKey: String, layoutSource: LayoutSource) -> ColorType? {
        var colorHexCode = dict[colorKey] as? String
        if let borderColorProjectColorId = dict[projectColorKey] as? String {
            if let hexCode = layoutSource.projectColor(with: borderColorProjectColorId) {
                colorHexCode = hexCode
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
    
    internal func hasLayoutObject(with attribute: NSLayoutAttribute) -> Bool {
        return layoutObject(with: attribute) != nil;
    }

    internal func isConstraintCompletelyDisabledWithAttribute(_ attribute: NSLayoutAttribute) -> Bool {
        guard let layoutObject = self.layoutObject(with: attribute) else { return true }
        let deactivated = layoutObject.isCompletelyDeactivated
        print("deactivated: \(deactivated)")
        return deactivated
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
    
    private static func initializeChildComponents(_ components: [String: [String: Any]], layoutSource: LayoutSource) -> [Component] {
        var result = [Component]()
        for dict in components.values {
            result.append(Component(dictionary: dict, layoutSource: layoutSource))
        }
        return result
    }
}
