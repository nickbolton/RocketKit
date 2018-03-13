//
//  FontFamilyMember.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public struct FontFamilyMember {

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
    
    public init(name: String = "", familyName: String = "", weight: UIFontWeight = 0.0, isItalic: Bool = false, isSystemFont: Bool = true) {
        self.name = name
        self.familyName = familyName
        self.weight = weight
        self.isItalic = isItalic
        self.isSystemFont = isSystemFont
    }

    public init(dictionary: [String: Any]) {
        self.name = dictionary[FontFamilyMember.nameKey] as? String ?? ""
        self.familyName = dictionary[FontFamilyMember.familyNameKey] as? String ?? ""
        self.weight = dictionary[FontFamilyMember.weightKey] as? UIFontWeight ?? 0.0
        self.isItalic = dictionary[FontFamilyMember.isItalicKey] as? Bool ?? false
        self.isSystemFont = dictionary[FontFamilyMember.isSystemFontKey] as? Bool ?? false
    }
}
