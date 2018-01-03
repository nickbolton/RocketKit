//
//  RocketFontFamilyMember.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public struct RocketFontFamilyMember {

    public let name: String
    public let familyName: String
    public let weight: UIFontWeight
    public let isItalic: Bool
    public let isSystemFont: Bool
    
    private static let nameKey = "name"
    private static let familyNameKey = "familyName"
    private static let weightKey = "weight"
    private static let isItalicKey = "italic"
    private static let isSystemFontKey = "system"
    
    public init(name: String, familyName: String, weight: UIFontWeight, isItalic: Bool, isSystemFont: Bool) {
        self.name = name
        self.familyName = familyName
        self.weight = weight
        self.isItalic = isItalic
        self.isSystemFont = isSystemFont
    }

    public init(dictionary: [String: Any]) {
        self.name = dictionary[RocketFontFamilyMember.nameKey] as? String ?? ""
        self.familyName = dictionary[RocketFontFamilyMember.familyNameKey] as? String ?? ""
        self.weight = dictionary[RocketFontFamilyMember.weightKey] as? UIFontWeight ?? 0
        self.isItalic = dictionary[RocketFontFamilyMember.isItalicKey] as? Bool ?? false
        self.isSystemFont = dictionary[RocketFontFamilyMember.isSystemFontKey] as? Bool ?? false
    }
}
