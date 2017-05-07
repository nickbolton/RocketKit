//
//  RocketLayoutSource.swift
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

public class RocketLayoutSource: NSObject {

    private (set) var topLevelComponents = [String: RocketComponent]()
    let version: Int
    private var componentMap = [String: RocketComponent]()
    private var componentMapByName = [String: RocketComponent]()
    private let projectColors: [String: String]
    
    private let versionKey = "version"
    private let componentsKey = "components"
    private let projectColorsKey = "projectColors"
    private let duplicateComponentsKey = "duplicateComponents"

    required public init(dictionary: [String: Any]) {
        self.version = dictionary[versionKey] as? Int ?? 1
        self.projectColors = RocketLayoutSource.initializeProjectColors(dictionary[projectColorsKey] as? [[String: Any]] ?? [])
        super.init()
        topLevelComponents = initializeComponents(dictionary[componentsKey] as? [[String: Any]] ?? [])
        establishComponentMap(components: Array(topLevelComponents.values))
    }
    
    public func component(with identifier: String) -> RocketComponent? {
        return componentMap[identifier]
    }
    
    public func componentByName(_ name: String) -> RocketComponent? {
        return componentMapByName[name]
    }
    
    internal func projectColor(with identifier: String) -> String? {
        return projectColors[identifier]
    }
    
    private func establishComponentMap(components: [RocketComponent]) {
        for component in components {
            componentMap[component.identifier] = component
            componentMapByName[component.name] = component
            establishComponentMap(components: component.childComponents)
        }
    }
    
    private static func initializeProjectColors(_ colorArray: [[String: Any]]) -> [String: String] {
        let identifierKey = "identifier"
        let hexCodeKey = "color"
        var colors = [String: String]()
        for dict in colorArray {
            guard let identifier = dict[identifierKey] as? String, let hexCode = dict[hexCodeKey] as? String else { continue }
            colors[identifier] = hexCode
        }
        return colors
    }
    
    private static func projectColorIdentifier(_ identifier: String, colors: [String: String]) -> String? {
        if let color = colors[identifier] {
            return color
        }
        return nil
    }
    
    private func initializeComponents(_ componentArray: [[String: Any]]) -> [String: RocketComponent] {
        var components = [String: RocketComponent]()
        for dict in componentArray {
            let component = RocketComponent(dictionary: dict, layoutSource: self)
            components[component.identifier] = component
        }
        establishParentAssociations(Array(components.values), parent: nil)
        return components
    }
    
    private func establishParentAssociations(_ components: [RocketComponent], parent: RocketComponent?) {
        for component in components {
            component.parentComponent = parent
            establishParentAssociations(component.childComponents, parent: component)
        }
    }
}
