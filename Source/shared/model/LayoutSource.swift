//
//  LayoutSource.swift
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

public class LayoutSource: NSObject {

    fileprivate (set) var topLevelComponents = [String: RocketComponent]()
    
    var rootComponent: RocketComponent? {
        guard let identifier = rootComponentId else { return nil }
        return component(with: identifier)
    }
    
    var version: Int = 0
    private var componentMap = [String: RocketComponent]()
    private var componentMapByName = [String: RocketComponent]()
    private var projectColors = [String: String]()
    var rootComponentId: String? = nil
    
    private let versionKey = "version"
    private let componentsKey = "components"
    private let rootComponentIdKey = "rootComponentId"
    private let projectColorsKey = "projectColors"

    required public init(dictionary: [String: Any]) {
        print("loading data source: \(dictionary)")
        self.version = dictionary[versionKey] as? Int ?? 1
        self.projectColors = LayoutSource.initializeProjectColors(dictionary[projectColorsKey] as? [[String: Any]] ?? [])
        self.rootComponentId = dictionary[rootComponentIdKey] as? String
        super.init()
        topLevelComponents = initializeComponents(dictionary[componentsKey] as? [[String: Any]] ?? [])
        establishComponentMap(components: Array(topLevelComponents.values))
    }
    
    required public init(topLevelComponents: [RocketComponent]) {
        for component in topLevelComponents {
            self.topLevelComponents[component.identifier] = component
        }
        super.init()
        establishComponentMap(components: Array(self.topLevelComponents.values))
        establishParentAssociations(Array(self.topLevelComponents.values), parent: nil)
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
    
    fileprivate func establishComponentMap(components: [RocketComponent]) {
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

public extension LayoutSource {
    public func add(_ component: RocketComponent) {
        topLevelComponents[component.identifier] = component
        establishComponentMap(components: Array(topLevelComponents.values))
    }
}
