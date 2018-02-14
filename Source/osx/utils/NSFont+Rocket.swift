//
//  NSFont+Rocket.swift
//  Pods-RocketTestMacSwift
//
//  Created by Nick Bolton on 1/2/18.
//

import Cocoa

public typealias FontType = NSFont
public typealias UIFontWeight = NSFontWeight

public extension FontType {
    
    internal static let smallTestPointSize: CGFloat = 8.0
    internal static let largeTestPointSize: CGFloat = 50.0
        
    public var isSystemFont: Bool { return FontType.isSystemFontFamily(familyName ?? "") }
    public var lineHeight: CGFloat { return ascender + abs(descender) + leading }
    
    public static func isSystemFontFamily(_ name: String) -> Bool {
        return FontType.systemFont(ofSize: smallTestPointSize).familyName == name ||
            FontType.systemFont(ofSize: largeTestPointSize).familyName == name
    }
}
