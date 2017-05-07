//
//  RocketLayoutProvider.swift
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

public class RocketLayoutProvider: NSObject {
    static public let shared = RocketLayoutProvider()
    private override init() {
        super.init()
        loadDefaultLayoutSource()
    }
    
    private let viewFactory = RocketViewFactory()
    private var layoutSource: RocketLayoutSource?
    
    private var viewRegistry = [String: RocketViewProtocol]()
    
    private func loadDefaultLayoutSource() {
        guard let url = Bundle.main.url(forResource: "layoutSource", withExtension: "rocket") as URL?  else {
            print("Missing layoutSource.rocket resource.")
            return
        }
        self.loadLayout(at: url)
    }
    
    private func loadLayout(at url: URL) {
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
        layoutSource = RocketLayoutSource(dictionary: dict)
        guard layoutSource != nil else {
            print("Couldn't load url: \(url)")
            return
        }
    }
    
    // MARK: Public
    
    public func buildView(withIdentifier identifier: String) -> RocketViewProtocol? {
        if let component = componentByIdentifier(identifier) {
            return viewFactory.buildView(with: component)
        }
        return nil
    }
    
    public func buildView(withName name: String) -> RocketViewProtocol? {
        if let component = componentByName(name) {
            return viewFactory.buildView(with: component)
        }
        return nil
    }
    
    // MARK: Internal
    
    internal func componentByIdentifier(_ identifier: String) -> RocketComponent? {
        return layoutSource?.component(with: identifier)
    }
    
    internal func componentByName(_ name: String) -> RocketComponent? {
        return layoutSource?.componentByName(name)
    }
    
    internal func view(with identifier: String?) -> RocketViewProtocol? {
        guard let identifier = identifier else {
            return nil
        }
        return viewRegistry[identifier]
    }
    
    internal func registerView(_ view: RocketViewProtocol, for component: RocketComponent) {
        viewRegistry[component.identifier] = view
    }

    internal func unregisterView(_ view: RocketViewProtocol, for component: RocketComponent) {
        viewRegistry.removeValue(forKey: component.identifier)
    }
}
