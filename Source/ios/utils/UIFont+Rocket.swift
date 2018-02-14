//
//  UIFont+Rocket.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

import UIKit

public typealias FontType = UIFont

public extension FontType {
    
    internal static let smallTestPointSize: CGFloat = 8.0
    internal static let largeTestPointSize: CGFloat = 50.0

    public var isSystemFont: Bool { return FontType.isSystemFontFamily(familyName) }
    public static func isSystemFontFamily(_ name: String) -> Bool {
        return FontType.systemFont(ofSize: smallTestPointSize).familyName == name ||
            FontType.systemFont(ofSize: largeTestPointSize).familyName == name
    }
}
