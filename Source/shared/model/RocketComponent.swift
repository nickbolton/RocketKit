//
//  RocketComponent.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public enum RocketComponentType: Int {
    case container
}

public class RocketComponent: RocketBaseObject {
    
    let componentType: RocketComponentType
    let name: String

    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let isClipped: Bool
    let isRasterized: Bool
    let alpha: CGFloat
    var borderColor: RocketColorType?
    var backgroundColor: RocketColorType?
    
    let layoutObjects: [RocketLayout]
    let defaultLayoutObjects: [RocketLayout]
    var allLayoutObjects: [RocketLayout] {
        var result = [RocketLayout]()
        result.append(contentsOf: defaultLayoutObjects)
        result.append(contentsOf: layoutObjects)
        return result
    }
    
    let childComponents: [RocketComponent]
    internal (set) var parentComponent: RocketComponent?
    
    var isTopLevelComponent: Bool { return parentComponent == nil }
    var topLevelComponent: RocketComponent {
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

    required public init(dictionary: [String: Any], layoutSource: RocketLayoutSource) {
        self.componentType = RocketComponentType(rawValue: dictionary[RocketComponent.typeKey] as? Int ?? 0) ?? .container
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
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
    
    private static func resolveColor(dict: [String: Any], colorKey: String, projectColorKey: String, layoutSource: RocketLayoutSource) -> RocketColorType? {
        var colorHexCode = dict[colorKey] as? String
        if let borderColorProjectColorId = dict[projectColorKey] as? String {
            if let hexCode = layoutSource.projectColor(with: borderColorProjectColorId) {
                colorHexCode = hexCode
            }
        }
        if colorHexCode != nil {
            return RocketColorType(hex: colorHexCode!)
        }
        return nil
    }
    
    internal func layoutObject(with attribute: NSLayoutAttribute) -> RocketLayout? {
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

    private static func initializeLayoutObjects(_ layoutObjectArray: [[String: Any]], layoutSource: RocketLayoutSource) -> [RocketLayout] {
        var result = [RocketLayout]()
        for dict in layoutObjectArray {
            result.append(RocketLayout(dictionary: dict, layoutSource: layoutSource))
        }
        return result
    }
    
    private static func initializeChildComponents(_ components: [String: [String: Any]], layoutSource: RocketLayoutSource) -> [RocketComponent] {
        var result = [RocketComponent]()
        for dict in components.values {
            result.append(RocketComponent(dictionary: dict, layoutSource: layoutSource))
        }
        return result
    }
}
