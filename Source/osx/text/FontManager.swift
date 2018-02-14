//
//  FontManager.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/2/18.
//

import Cocoa

class FontManager: FontManagerProtocol {

    public static let shared: FontManagerProtocol = FontManager()
    
    fileprivate static var memberCache = [String: [FontFamilyMember]]()
    
    public var availableFontNames: [String] { return NSFontManager.shared().availableFontFamilies }
    
    public var defaultWeight: CGFloat { return NSFontWeightRegular }
    
    public var systemFamilyName: String { return FontType.systemFont(ofSize: FontType.largeTestPointSize).familyName ?? "" }
    
    @discardableResult
    public func defaultFontForFamily(_ familyName: String, with size: CGFloat) -> FontType {
        let member = fontMembersForFamily(familyName).first
        let traits: NSFontTraitMask = member?.isItalic ?? false ? .italicFontMask : NSFontTraitMask(rawValue: 0)
        return NSFontManager.shared().font(withFamily: familyName, traits: traits, weight: 0, size: size)!
    }
    
    public func fontMembersForFamily(_ familyName: String) -> [FontFamilyMember] {
        
        var result = FontManager.memberCache[familyName]
        
        if result != nil {
            return result!
        }
        
        result = []
        
        if let availableMembers = NSFontManager.shared().availableMembers(ofFontFamily: familyName) {
            for memberArray in availableMembers {
                guard memberArray.count > 0, let name = memberArray[0] as? String else { continue }
                guard let font = FontType(name: name, size: FontType.largeTestPointSize) else { continue }
                let memberTraits = memberArray.count > 3 ? memberArray[3] as? UInt32 ?? 0 : 0
                let descriptor = font.fontDescriptor
                var isItalic = name.lowercased().contains("italic")
                var weight = weightFor(fontName: name)
                
                if let traitDict = descriptor.fontAttributes[NSFontTraitsAttribute] as? [String: Any] {
                    if let weightValue = traitDict[NSFontWeightTrait] as? CGFloat {
                        weight = weightValue
                    }
                    if let traits = traitDict[NSFontSymbolicTrait] as? NSFontSymbolicTraits {
                        isItalic = isItalic || ((traits & NSFontDescriptorTraitItalic.rawValue) != 0) || ((memberTraits & NSFontDescriptorTraitItalic.rawValue) != 0)
                    }
                }
                
                let member = FontFamilyMember(name: name, familyName: familyName, weight: weight, isItalic: isItalic, isSystemFont: font.isSystemFont)
                result?.append(member)
            }
        }
        
        FontManager.memberCache[familyName] = result
        
        return result!
    }
    
    private func weightFor(fontName: String) -> CGFloat {
        let name = fontName.lowercased()
        if name.contains("ultra") && name.contains("light") {
            return NSFontWeightUltraLight
        }
        if name.contains("thin") {
            return NSFontWeightThin
        }
        if name.contains("light") {
            return NSFontWeightLight
        }
        if name.contains("regular") {
            return NSFontWeightRegular
        }
        if name.contains("medium") {
            return NSFontWeightMedium
        }
        if name.contains("semi") && name.contains("bold") {
            return NSFontWeightSemibold
        }
        if name.contains("bold") {
            return NSFontWeightBold
        }
        if name.contains("heavy") {
            return NSFontWeightHeavy
        }
        if name.contains("black") {
            return NSFontWeightBlack
        }
        return NSFontWeightRegular
    }
    
    public func memberFont(_ member: FontFamilyMember, with size: CGFloat) -> FontType {
        if member.isSystemFont {
            if member.weight == NSFontWeightBold {
                return FontType.boldSystemFont(ofSize: size)
            }
            if member.isItalic {
                let systemFont = FontType.systemFont(ofSize: size)
                return applyWeight(member.weight, traits: NSFontDescriptorTraitItalic, to: systemFont)
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
        let traits: NSFontDescriptorSymbolicTraits = member.isItalic ? NSFontDescriptorTraitItalic : NSFontDescriptorSymbolicTraits(rawValue: 0)
        return applyWeight(member.weight, traits: traits, to: font)
    }
    
    fileprivate func applyWeight(_ weight: CGFloat, traits: NSFontDescriptorSymbolicTraits, to font: FontType) -> FontType {
        let attributes: [String: Any] = [
            NSFontTraitsAttribute :
                [
                    NSFontWeightTrait : weight,
                    NSFontSymbolicTrait : traits,
            ]
        ]
        let descriptor = font.fontDescriptor.addingAttributes(attributes)
        return FontType(descriptor: descriptor, size: font.pointSize)!
    }
    
    public func loadFonts() {
        for name in availableFontNames {
            defaultFontForFamily(name, with: FontType.largeTestPointSize)
        }
    }
}
