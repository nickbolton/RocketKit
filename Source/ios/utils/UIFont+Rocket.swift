//
//  UIFont+Rocket.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

import UIKit

public typealias RocketFontType = UIFont

public extension RocketFontType {
    
    internal static let smallTestPointSize: CGFloat = 8.0
    internal static let largeTestPointSize: CGFloat = 50.0

    public var isSystemFont: Bool { return RocketFontType.isSystemFontFamily(familyName) }
    public static func isSystemFontFamily(_ name: String) -> Bool {
        return RocketFontType.systemFont(ofSize: smallTestPointSize).familyName == name ||
            RocketFontType.systemFont(ofSize: largeTestPointSize).familyName == name
    }
}
