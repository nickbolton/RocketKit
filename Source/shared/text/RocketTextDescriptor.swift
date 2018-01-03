//
//  RocketTextDescriptor.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public struct RocketTextDescriptor {
    
    public var text = ""
    public var textAttributes = RocketTextAttributes()
    
    private static let textKey = "text"
    private static let textAttributesKey = "textAttributes"
    
    public var attributedString: NSAttributedString {
        return NSAttributedString(string: text, attributes: textAttributes.attributes)
    }

    public init(dictionary: [String: Any]) {
        self.text = dictionary[RocketTextDescriptor.textKey] as? String ?? ""
        if let attributesDict = dictionary[RocketTextDescriptor.textAttributesKey] as? [String: Any] {
            self.textAttributes = RocketTextAttributes(dictionary: attributesDict)
        }
    }
    
    public func containerFrame(boundBy: CGSize, componentFrame: CGRect, textView: RocketBaseView) -> CGRect {
        let (containerFrame, _) = textAndContainerFrames(boundBy: boundBy, componentFrame: componentFrame, textView: textView)
        return containerFrame
    }

    public func textFrame(boundBy: CGSize, componentFrame: CGRect, textView: RocketBaseView) -> CGRect {
        let (_, textFrame) = textAndContainerFrames(boundBy: boundBy, componentFrame: componentFrame, textView: textView)
        return textFrame
    }
    
    public func textAndContainerFrames(boundBy: CGSize, componentFrame: CGRect, textView: RocketBaseView) -> (CGRect, CGRect) {
        let font = textAttributes.font
        let sideMargins = textMargins(textView: textView)
        let horizontalPadding = sideMargins.left + sideMargins.right
        let verticalPadding = sideMargins.top + sideMargins.bottom
        var size = textSize(for: attributedString, boundBy: boundBy, textView: textView)
        let maxValue = min(CGFloat.greatestFiniteMagnitude, CGFloat(MAXFLOAT))
        let width = boundBy.width < maxValue ? boundBy.width : size.width
        var height = boundBy.height < maxValue ? boundBy.height : size.height
        height += max(font.pointSize - textAttributes.lineHeight, 0.0)
        
        size = CGSize(width: ceil(width), height: ceil(height))
        
        var containerFrame = CGRect.zero
        containerFrame.size = size
        containerFrame.size.width -= horizontalPadding
        containerFrame.size.height -= verticalPadding
        containerFrame.size.height = round(containerFrame.height * 2.0) / 2.0 // half point aligned
        
        var textFrame = CGRect(x: -sideMargins.left, y: 0.0, width: size.width, height: size.height)
        if textAttributes.textAlignment == .center || textAttributes.textAlignment == .justified {
            textFrame.origin.x = -(sideMargins.left + sideMargins.right) / 2.0
        }
        
        let heightDiff = componentFrame.height - size.height
        
        switch (textAttributes.verticalAlignment) {
        case .top:
            textFrame.origin.y -= sideMargins.top
            break;
        case .center:
            textFrame.origin.y += (-sideMargins.top + heightDiff + sideMargins.bottom) / 2.0
            break;
        case .bottom:
            textFrame.origin.y += sideMargins.bottom
            textFrame.origin.y += heightDiff
            break;
        }
        
        return (containerFrame, textFrame)
    }
    
    private func textMargins(textView: RocketBaseView) -> UIEdgeInsets {
        var glyph = [CGGlyph](repeating: 0, count: 1)
        var glyphRects = [CGRect](repeating: .zero, count: 1)
        
        let testString = "H"
        
        let font = self.textAttributes.font
        let unichars = [UniChar](testString.utf16)

        CTFontGetGlyphsForCharacters(font, unichars, &glyph, 1)
        CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphRects, 1)
        
        let glyphRect = glyphRects.first ?? .zero
        
        var descriptor = self
        descriptor.text = testString
        descriptor.textAttributes.kerning = 0.0
        
        let size = descriptor.textSize(for: descriptor.attributedString, boundBy: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), textView: textView)
        
        if (size == .zero) {
            #if os(iOS)
                return .zero
            #else
                return NSEdgeInsetsZero
            #endif
        }
        
        var horizontalMargins = floor(size.width - glyphRect.width)
        horizontalMargins /= 2.0
        
        let glyphHeight = round(glyphRect.height * 2.0) / 2.0
        let verticalSpacing = size.height - glyphHeight
        
        var bottom = -font.descender
        if textView.isKind(of: RocketTextView.self) {
            bottom += font.leading
        }
        bottom = max(round(bottom * 2.0) / 2.0, 0.0)
        
        let top = verticalSpacing - bottom
        
        return UIEdgeInsets(top: top, left: horizontalMargins, bottom: bottom, right: horizontalMargins)
    }
    
    private func textSize(for attributedString: NSAttributedString, boundBy: CGSize, textView: RocketBaseView) -> CGSize {
        if textView.isKind(of: RocketLabel.self) {
            return textSizeInLabel(for: attributedString, boundBy: boundBy)
        } else if textView.isKind(of: RocketTextField.self) {
            return textSizeInTextField(for: attributedString, boundBy: boundBy)
        } else if textView.isKind(of: RocketTextView.self) {
            return textSizeInTextView(for: attributedString, boundBy: boundBy)
        }
        return .zero
    }
}
