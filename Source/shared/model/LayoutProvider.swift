//
//  LayoutProvider.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import UIKit

class LayoutProvider: NSObject {
    static let shared = LayoutProvider()
    private override init() {}
    
    private let viewFactory = ViewFactory()
    private var layoutSource: LayoutSource?
    
    private var viewRegistry = [String: RocketViewProtocol]()
    
    public func loadLayout(at url: URL) {
        guard layoutSource == nil else { return }
        
        if url.lastPathComponent.hasSuffix(".rocket") {
            loadRocketFormat(url)
        } else if url.lastPathComponent.hasSuffix(".dict") {
            loadDictFormat(url)
        } else {
            print("Unsupported layout source file: \(url)")
        }
    }
    
    private func loadDictFormat(_ url: URL) {
        guard let dict = NSDictionary(contentsOf: url) as? [String: Any] else {
            print("Couldn't load url: \(url)")
            return
        }
        loadDictionary(dict, from: url)
    }
    
    private func loadRocketFormat(_ url: URL) {
        guard let data = NSData(contentsOf: url) as Data? else {
            print("Couldn't load url: \(url)")
            return
        }
        guard let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else {
            print("Invalid rocket format.")
            return
        }
        loadDictionary(dict, from: url)
    }
    
    private func loadDictionary(_ dict: [String: Any], from url: URL) {
        layoutSource = LayoutSource(dictionary: dict)
        guard layoutSource != nil else {
            print("Couldn't load url: \(url)")
            return
        }
    }
    
    // MARK: Public
    
    public func view(with identifier: String) -> RocketViewProtocol? {
        if let component = component(with: identifier) {
            return viewFactory.buildView(with: component)
        }
        return nil
    }
    
    // MARK: Internal
    
    internal func component(with identifier: String) -> Component? {
        return layoutSource?.component(with: identifier)
    }
    
    internal func viewWithComponentIdentifier(_ identifier: String?) -> RocketViewProtocol? {
        guard let identifier = identifier else {
            return nil
        }
        return viewRegistry[identifier]
    }
    
    internal func registerView(_ view: RocketViewProtocol, for component: Component) {
        viewRegistry[component.identifier] = view
    }

    internal func unregisterView(_ view: RocketViewProtocol, for component: Component) {
        viewRegistry.removeValue(forKey: component.identifier)
    }
}
