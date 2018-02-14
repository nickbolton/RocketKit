//
//  FontManager.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

import UIKit

public struct FontManager: FontManagerProtocol {
    
    public static let shared: FontManagerProtocol = FontManager()
    
    fileprivate static var memberCache = [String: [FontFamilyMember]]()
    
    public var availableFontNames: [String] { return FontType.familyNames }
    
    public var defaultWeight: CGFloat { return UIFontWeightRegular }
    
    public var systemFamilyName: String { return FontType.systemFont(ofSize: FontType.largeTestPointSize).familyName }
    
    @discardableResult
    public func defaultFontForFamily(_ familyName: String, with size: CGFloat) -> FontType {
        let attributes: [String: Any] = [
            UIFontDescriptorFamilyAttribute: familyName,
            UIFontDescriptorSizeAttribute: size,
            UIFontDescriptorTraitsAttribute :
            [
                UIFontWeightTrait : UIFontWeightRegular,
            ]
        ]
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return FontType(descriptor: descriptor, size: size)
    }
    
    public func fontMembersForFamily(_ familyName: String) -> [FontFamilyMember] {
        
        var result = FontManager.memberCache[familyName]
        
        if result != nil {
            return result!
        }
        
        result = []
        
        let names = FontType.fontNames(forFamilyName: familyName)
        for name in names {
            guard let font = FontType(name: name, size: FontType.largeTestPointSize) else { continue }
            let descriptor = font.fontDescriptor
            var isItalic = name.lowercased().contains("italic")
            var weight = weightFor(fontName: name)
            if let traitDict = descriptor.fontAttributes[UIFontDescriptorTraitsAttribute] as? [String: Any] {
                if let weightValue = traitDict[UIFontWeightTrait] as? CGFloat {
                    weight = weightValue
                }
                if let traits = traitDict[UIFontSymbolicTrait] as? UIFontDescriptorSymbolicTraits {
                    isItalic = isItalic || traits.contains(.traitItalic)
                }
            }
            
            let member = FontFamilyMember(name: name, familyName: familyName, weight: weight, isItalic: isItalic, isSystemFont: font.isSystemFont)
            result?.append(member)
        }
        
        FontManager.memberCache[familyName] = result
        
        return result!
    }
    
    private func weightFor(fontName: String) -> CGFloat {
        let name = fontName.lowercased()
        if name.contains("ultra") && name.contains("light") {
            return UIFontWeightUltraLight
        }
        if name.contains("thin") {
            return UIFontWeightThin
        }
        if name.contains("light") {
            return UIFontWeightLight
        }
        if name.contains("regular") {
            return UIFontWeightRegular
        }
        if name.contains("medium") {
            return UIFontWeightMedium
        }
        if name.contains("semi") && name.contains("bold") {
            return UIFontWeightSemibold
        }
        if name.contains("bold") {
            return UIFontWeightBold
        }
        if name.contains("heavy") {
            return UIFontWeightHeavy
        }
        if name.contains("black") {
            return UIFontWeightBlack
        }
        return UIFontWeightRegular
    }
        
    public func memberFont(_ member: FontFamilyMember, with size: CGFloat) -> FontType {
        if member.isSystemFont {
            if member.weight == UIFontWeightBold {
                return FontType.boldSystemFont(ofSize: size)
            }
            if member.isItalic {
                return FontType.italicSystemFont(ofSize: size)
            }
            return FontType.systemFont(ofSize: size)
        }
        
        let defaultFont = FontType.systemFont(ofSize: size)
        var font = FontType(name: member.name, size: size)
        if font == nil {
            font = applyMember(member, to: defaultFont)
        }
        return font ?? defaultFont
    }
    
    public func applyMember(_ member: FontFamilyMember, to font: FontType) -> FontType {
        let traits: UIFontDescriptorSymbolicTraits = member.isItalic ? .traitItalic : []
        return applyWeight(member.weight, traits: traits, to: font)
    }
    
    fileprivate func applyWeight(_ weight: CGFloat, traits: UIFontDescriptorSymbolicTraits, to font: FontType) -> FontType {
        let attributes: [String: Any] = [
            UIFontDescriptorTraitsAttribute :
            [
                UIFontWeightTrait : weight,
                UIFontSymbolicTrait : traits,
            ]
        ]
        let descriptor = font.fontDescriptor.addingAttributes(attributes)
        return FontType(descriptor: descriptor, size: font.pointSize)
    }
    
    public func loadFonts() {
        for name in availableFontNames {
            defaultFontForFamily(name, with: FontType.largeTestPointSize)
        }
    }
}
