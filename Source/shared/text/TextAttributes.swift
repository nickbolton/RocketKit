//
//  TextAttributes.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
    typealias LineBreakModeType = Int
#else
    import Cocoa
    typealias LineBreakModeType = UInt
#endif

public enum TextVerticalAlignment: Int {
    case center = 0
    case top
    case bottom
}

public struct TextAttributes {
    
    public var fontFamilyMember: FontFamilyMember?
    public var fontFamilyName: String?
    public let isSystemFont: Bool
    public var pointSize: CGFloat
    public var kerning: CGFloat
    public var lineHeightMultiple: CGFloat
    public var paragraphSpacing: CGFloat
    public var textAlignment: TextAlignment
    public var verticalAlignment: TextVerticalAlignment
    public var lineBreakMode: NSLineBreakMode
    public var isUnderline: Bool
    public var textColor: ColorType
    
    var baselineAdjustment: CGFloat { return 2.0 * ceil(min(lineHeight - font.capHeight + font.descender, 0.0)) }
    
    fileprivate static let defaultFontSize: CGFloat = 17.0
    fileprivate static let defaultLineHeightMultiple: CGFloat = 1.2

    fileprivate let fontFamilyMemberKey = "fontFamilyMember"
    fileprivate let fontFamilyNameKey = "fontFamilyName"
    fileprivate let pointSizeKey = "pointSize"
    fileprivate let kerningKey = "kerning"
    fileprivate let lineHeightMultipleKey = "lineHeightMultiple"
    fileprivate let paragraphSpacingKey = "paragraphSpacing"
    fileprivate let textAlignmentKey = "textAlignment"
    fileprivate let verticalAlignmentKey = "verticalAlignment"
    fileprivate let lineBreakModeKey = "lineBreakMode"
    fileprivate let underlineKey = "underline"
    fileprivate let textColorKey = "textColor"
    fileprivate let systemFontKey = "isSystemFont"
    
    public var cacheKey: String {
        let font = self.font
        return "\(font.fontName)|\(font.pointSize)|\(lineHeightMultiple)|\(kerning)|\(paragraphSpacing)"
    }

    public init(fontFamilyMember: FontFamilyMember? = nil,
                fontFamilyName: String? = nil,
                isSystemFont: Bool = false,
                pointSize: CGFloat = TextAttributes.defaultFontSize,
                kerning: CGFloat = 0.0,
                lineHeightMultiple: CGFloat = TextAttributes.defaultLineHeightMultiple,
                paragraphSpacing: CGFloat = 0.0,
                textAlignment: TextAlignment = .left,
                verticalAlignment: TextVerticalAlignment = .center,
                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                isUnderline: Bool = false,
                textColor: ColorType = .clear) {
        self.fontFamilyMember = fontFamilyMember
        self.fontFamilyName = fontFamilyName
        self.isSystemFont = isSystemFont
        self.pointSize = pointSize
        self.kerning = kerning
        self.lineHeightMultiple = lineHeightMultiple
        self.paragraphSpacing = paragraphSpacing
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.lineBreakMode = lineBreakMode
        self.isUnderline = isUnderline
        self.textColor = textColor
    }
    
    public init(dictionary: [String: Any]) {
        self.fontFamilyName = dictionary[fontFamilyNameKey] as? String
        self.pointSize = dictionary[pointSizeKey] as? CGFloat ?? TextAttributes.defaultFontSize
        self.isSystemFont = dictionary[systemFontKey] as? Bool ?? false
        self.kerning = dictionary[kerningKey] as? CGFloat ?? 0.0
        self.lineHeightMultiple = dictionary[lineHeightMultipleKey] as? CGFloat ?? TextAttributes.defaultLineHeightMultiple
        self.paragraphSpacing = dictionary[paragraphSpacingKey] as? CGFloat ?? 0.0
        self.textAlignment = TextAlignment(rawValue: dictionary[textAlignmentKey] as? Int ?? 0) ?? .left
        self.verticalAlignment = TextVerticalAlignment(rawValue: dictionary[verticalAlignmentKey] as? Int ?? 0) ?? .center
        self.lineBreakMode = NSLineBreakMode(rawValue: dictionary[lineBreakModeKey] as? LineBreakModeType ?? 0) ?? .byWordWrapping
        self.isUnderline = dictionary[underlineKey] as? Bool ?? false

        if let colorHexCode = dictionary[textColorKey] as? String {
            self.textColor = ColorType(hex: colorHexCode)
        } else {
            self.textColor = ColorType.clear
        }
        
        if let memberDict = dictionary[fontFamilyMemberKey] as? [String: Any] {
            self.fontFamilyMember = FontFamilyMember(dictionary: memberDict)
        } else {
            self.fontFamilyMember = nil
        }
    }
    
    public var font: FontType {
        let size = pointSize > 0.0 ? pointSize : TextAttributes.defaultFontSize
        var result: FontType?
        if !isSystemFont {
            if fontFamilyMember != nil {
                result = FontManager.shared.memberFont(fontFamilyMember!, with: size)
            }
            if result == nil && fontFamilyName != nil && !FontType.isSystemFontFamily(fontFamilyName!) {
                result = FontType(name: fontFamilyName!, size: size)
            }
        }
        return result ?? FontType.systemFont(ofSize: size)
    }
    
    public var lineHeight: CGFloat { return pointSize * lineHeightMultiple }
    public var distanceToCapTop: CGFloat {
        let font = self.font
        let leading = lineHeight - font.capHeight + font.descender
        let internalBaseline = internalBaselineForFont(font)
        let result = max(ceil(leading + internalBaseline), 0.0)
        return result
    }
    
    public var attributes: [String: Any] {
        let font = self.font
        var result = [String:Any]()
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.alignment = textAlignment.nativeAlignment()
        paragraphStyle.lineHeightMultiple = lineHeight / font.lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.paragraphSpacing = paragraphSpacing
        
        paragraphStyle.allowsDefaultTighteningForTruncation = lineBreakMode != .byWordWrapping && lineBreakMode != .byCharWrapping && lineBreakMode != .byClipping
        
        result[NSParagraphStyleAttributeName] = paragraphStyle
        result[NSKernAttributeName] = self.kerning
        
        if isUnderline {
            result[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle
        }
        
        let baselineOffset = internalBaselineForFont(font)
        result[NSBaselineOffsetAttributeName] = baselineOffset
        
        result[NSFontAttributeName] = font
        result[NSForegroundColorAttributeName] = textColor
        
        return result
    }
    
    fileprivate func internalBaselineForFont(_ font: FontType) -> CGFloat {
        let spacing = ceil(lineHeight - font.capHeight + font.descender)
        if spacing < 0.0 {
            return spacing / 2.0
        }
        return 0.0
    }
}
