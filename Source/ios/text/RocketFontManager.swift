//
//  RocketFontManager.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

import UIKit

public struct RocketFontManager: RocketFontManagerProtocol {
    
    public static let shared: RocketFontManagerProtocol = RocketFontManager()
    
    fileprivate static var memberCache = [String: [RocketFontFamilyMember]]()
    
    public var availableFontNames: [String] { return RocketFontType.familyNames }
    
    public var defaultWeight: CGFloat { return UIFontWeightRegular }
    
    public var systemFamilyName: String { return RocketFontType.systemFont(ofSize: RocketFontType.largeTestPointSize).familyName }
    
    @discardableResult
    public func defaultFontForFamily(_ familyName: String, with size: CGFloat) -> RocketFontType {
        let attributes: [String: Any] = [
            UIFontDescriptorFamilyAttribute: familyName,
            UIFontDescriptorSizeAttribute: size,
            UIFontDescriptorTraitsAttribute :
            [
                UIFontWeightTrait : UIFontWeightRegular,
            ]
        ]
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return RocketFontType(descriptor: descriptor, size: size)
    }
    
    public func fontMembersForFamily(_ familyName: String) -> [RocketFontFamilyMember] {
        
        var result = RocketFontManager.memberCache[familyName]
        
        if result != nil {
            return result!
        }
        
        result = []
        
        let names = RocketFontType.fontNames(forFamilyName: familyName)
        for name in names {
            guard let font = RocketFontType(name: name, size: RocketFontType.largeTestPointSize) else { continue }
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
            
            let member = RocketFontFamilyMember(name: name, familyName: familyName, weight: weight, isItalic: isItalic, isSystemFont: font.isSystemFont)
            result?.append(member)
        }
        
        RocketFontManager.memberCache[familyName] = result
        
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
        
    public func memberFont(_ member: RocketFontFamilyMember, with size: CGFloat) -> RocketFontType {
        if member.isSystemFont {
            if member.weight == UIFontWeightBold {
                return RocketFontType.boldSystemFont(ofSize: size)
            }
            if member.isItalic {
                return RocketFontType.italicSystemFont(ofSize: size)
            }
            return RocketFontType.systemFont(ofSize: size)
        }
        
        let defaultFont = RocketFontType.systemFont(ofSize: size)
        var font = RocketFontType(name: member.name, size: size)
        if font == nil {
            font = applyMember(member, to: defaultFont)
        }
        return font ?? defaultFont
    }
    
    public func applyMember(_ member: RocketFontFamilyMember, to font: RocketFontType) -> RocketFontType {
        let traits: UIFontDescriptorSymbolicTraits = member.isItalic ? .traitItalic : []
        return applyWeight(member.weight, traits: traits, to: font)
    }
    
    fileprivate func applyWeight(_ weight: CGFloat, traits: UIFontDescriptorSymbolicTraits, to font: RocketFontType) -> RocketFontType {
        let attributes: [String: Any] = [
            UIFontDescriptorTraitsAttribute :
            [
                UIFontWeightTrait : weight,
                UIFontSymbolicTrait : traits,
            ]
        ]
        let descriptor = font.fontDescriptor.addingAttributes(attributes)
        return RocketFontType(descriptor: descriptor, size: font.pointSize)
    }
    
    public func loadFonts() {
        for name in availableFontNames {
            defaultFontForFamily(name, with: RocketFontType.largeTestPointSize)
        }
    }
}
