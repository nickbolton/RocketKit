//
//  TextDescriptor.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public enum TargetTextType: Int {
    case label
    case field
    case view
}

public class TextDescriptor {
    
    public var text = "" {
        didSet {
            if text == "H" {
                print("ZZZZ \(text)")
            }
        }
    }
    public var textAttributes = TextAttributes()
    public var targetTextType = TargetTextType.label
    
    private static let textKey = "text"
    private static let targetTextTypeKey = "targetTextType"
    private static let textAttributesKey = "textAttributes"
    
    fileprivate static let testString = "H"
    
    public var attributedString: NSAttributedString {
        return NSAttributedString(string: text, attributes: textAttributes.attributes)
    }

    public init(dictionary: [String: Any]) {
        self.text = dictionary[TextDescriptor.textKey] as? String ?? ""
        self.targetTextType = TargetTextType(rawValue: dictionary[TextDescriptor.targetTextTypeKey] as? Int ?? 0) ?? .label
        if let attributesDict = dictionary[TextDescriptor.textAttributesKey] as? [String: Any] {
            self.textAttributes = TextAttributes(dictionary: attributesDict)
        }
    }
    
    public init(text: String) {
        self.text = text
    }
    
    static func textFrame(for component: RocketComponent, text: String, textType: TargetTextType, containerSize: CGSize) -> CGRect {
        
        let boundBy = textBoundingSize(for: component, textIn: text, textType: textType, containerSize: containerSize, forceContainerWidth: true)

        return component.textDescriptor?.textFrame(for: text, textType: textType, boundBy: boundBy, usePreciseTextAlignments: component.usePreciseTextAlignments, containerSize: containerSize) ?? .zero
    }
    
    private static func textBoundingSize(for component: RocketComponent, textIn: String?, textType: TargetTextType, containerSize: CGSize, forceContainerWidth: Bool) -> CGSize {
        guard var descriptor = component.textDescriptor else { return .zero }
        var text = textIn
        if text == nil {
            text = descriptor.text
        }
    
        var attributes = descriptor.textAttributes.attributes
        if attributes.count == 0 {
            descriptor = TextDescriptor(text: "")
            attributes = descriptor.textAttributes.attributes
        }
    
        let widthLayout = component.layoutObject(with: .width)
        let heightLayout = component.layoutObject(with: .height)
    
        let hasDiscreteWidthConstraint = widthLayout?.isLinkedToTextSize ?? false
        let hasDiscreteHeightConstraint = heightLayout?.isLinkedToTextSize ?? false
    
        var horizontalPadding: CGFloat = 0.0
        var verticalPadding: CGFloat = 0.0
        var width = CGFloat.greatestFiniteMagnitude
        var height = CGFloat.greatestFiniteMagnitude
    
        if component.usePreciseTextAlignments {
            let sideMargins = TextMetricsCache.shared.textMargins(for: descriptor, textType: textType)
            horizontalPadding = sideMargins.left + sideMargins.right
            verticalPadding = sideMargins.top + sideMargins.bottom
        }
        
        if forceContainerWidth || hasDiscreteWidthConstraint || component.autoConstrainingTextType == .height {
            width = containerSize.width + horizontalPadding;
        }
        
        if (hasDiscreteHeightConstraint || component.autoConstrainingTextType.contains(.width)) && !component.autoConstrainingTextType.contains(.height) {
            height = containerSize.height + verticalPadding;
        }
        
        return CGSize(width: width, height: height)
    }
    
    public func containerFrame(for text: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool) -> CGRect {
        let (containerFrame, _) = textAndContainerFrames(for: text, textType: textType, boundBy: boundBy, usePreciseTextAlignments: usePreciseTextAlignments)
        return containerFrame
    }

    public func textFrame(for text: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool, containerSize: CGSize) -> CGRect {
        let (_, textFrame) = textAndContainerFrames(for: text, textType: textType, boundBy: boundBy, usePreciseTextAlignments: usePreciseTextAlignments, containerSize: containerSize)
        return textFrame
    }
    
    public func textAndContainerFrames(for textIn: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool, containerSize: CGSize = .zero) -> (CGRect, CGRect) {
        
        var text = textIn ?? self.text
        if targetTextType == .field {
            text = TextDescriptor.testString
        }
        
        let textAttributes = self.textAttributes
        let attributes = textAttributes.attributes
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        var size = CGSize.zero
        if usePreciseTextAlignments {
            size = TextMetricsCache.shared.textSize(for: attributedString, textAttributes: textAttributes, textType: textType, boundBy: boundBy)
        } else {
            let options = NSStringDrawingOptions.usesLineFragmentOrigin.union(.usesFontLeading)
            let rect = attributedString.boundingRect(with: boundBy, options: options, context: nil)
            size = CGSize(width: rect.width.halfPointCeilValue, height: rect.height.halfPointCeilValue)
        }

        let width = boundBy.width < CGFloat.greatestFiniteMagnitude ? boundBy.width: size.width
        let height = (boundBy.height < CGFloat.greatestFiniteMagnitude ? boundBy.height: size.height) - textAttributes.baselineAdjustment
        
        size = CGSize(width: width.halfPointCeilValue, height: height.halfPointCeilValue)

        let sideMargins = TextMetricsCache.shared.textMargins(for: self, textType: textType)
        let horizontalPadding = sideMargins.left + sideMargins.right
        let verticalPadding = sideMargins.top + sideMargins.bottom

        var containerFrame = CGRect.zero
        containerFrame.size = size
        if usePreciseTextAlignments {
            containerFrame.size.width -= horizontalPadding
            containerFrame.size.height -= verticalPadding
        }
        containerFrame.size.height = containerFrame.height.halfPointRoundValue

        var textFrame = containerFrame

        if usePreciseTextAlignments {
            textFrame = CGRect(x: -sideMargins.left, y: 0.0, width: size.width, height: size.height)
            if textAttributes.textAlignment == .center || textAttributes.textAlignment == .justified {
                textFrame.origin.x = -(sideMargins.left + sideMargins.right) / 2.0
            }
        }

        let heightDiff = containerSize.height - size.height

        switch textAttributes.verticalAlignment {
        case .top:
            if usePreciseTextAlignments {
                textFrame.origin.y -= sideMargins.top
            }
        case .center:
            textFrame.origin.y += heightDiff / 2.0
            if usePreciseTextAlignments {
                textFrame.origin.y += (-sideMargins.top + sideMargins.bottom) / 2.0
            }
        case .bottom:
            textFrame.origin.y += heightDiff
            if usePreciseTextAlignments {
                textFrame.origin.y += sideMargins.bottom
            }
        }

        return (containerFrame, textFrame)
    }
}

public struct TextMetricsCache {
    static let shared = TextMetricsCache()
    private init() {}
    
    private let marginsCache = NSCache<NSString, NSValue>()
    private let metricsCache = NSCache<NSString, TextMetrics>()
    
    private func cacheKey(for attributes: TextAttributes, textType: TargetTextType) -> NSString {
        return NSString(string: "\(attributes.cacheKey)|\(textType)")
    }
    
    private func cacheKey(for attributedString: NSAttributedString, boundedBy: CGSize, aligned: Bool, multipleLine: Bool, textType: TargetTextType) -> NSString {
        return NSString(string: "\(attributedString.description)|\(boundedBy)|\(aligned)|\(multipleLine)|\(textType)")
    }
    
    func textMargins(for descriptorIn: TextDescriptor, textType: TargetTextType) -> UIEdgeInsets {
        let key = cacheKey(for: descriptorIn.textAttributes, textType: textType)
        if let resultValue = marginsCache.object(forKey: key) {
            return resultValue.uiEdgeInsetsValue
        }
        
        var glyph = [CGGlyph](repeating: 0, count: 1)
        var glyphRects = [CGRect](repeating: .zero, count: 1)
        
        let font = descriptorIn.textAttributes.font
        let unichars = [UniChar](TextDescriptor.testString.utf16)
        
        CTFontGetGlyphsForCharacters(font, unichars, &glyph, 1)
        CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphRects, 1)
        
        let glyphRect = glyphRects.first ?? .zero
        
        let descriptor = TextDescriptor(text: TextDescriptor.testString)
        var textAttributes = descriptorIn.textAttributes
        textAttributes.kerning = 0.0
        descriptor.textAttributes = textAttributes
        
        let metrics = textMetrics(for: descriptor.attributedString, textAttributes: descriptor.textAttributes, textType: textType, multipleLine: false, boundedBy: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), aligned: false)
        if metrics.textSize == .zero {
            #if os(iOS)
                return .zero
            #else
                return NSEdgeInsetsZero
            #endif
        }
        
        let alignedViewSize = CGSize(width: metrics.viewSize.width.halfPointCeilValue, height: metrics.viewSize.height.halfPointCeilValue)
        
        var horizontalMargins = floor(alignedViewSize.width - glyphRect.width)
        horizontalMargins /= 2.0
        
        let glyphHeight = glyphRect.height.halfPointCeilValue
        let verticalSpacing = alignedViewSize.height - glyphHeight - descriptor.textAttributes.baselineAdjustment
        
        var bottom = abs(font.descender) - descriptor.textAttributes.baselineAdjustment
        if textType == .view {
            bottom += font.leading
        }
        
        bottom = max(round(bottom + metrics.viewInsets.bottom), 0.0)
        
        let top = verticalSpacing - bottom
        
        let result = UIEdgeInsets(top: top, left: horizontalMargins, bottom: bottom, right: horizontalMargins)
        marginsCache.setObject(NSValue(uiEdgeInsets: result), forKey: key)
        
        return result
    }
    
    func textSize(for attributedString: NSAttributedString, textAttributes: TextAttributes, textType: TargetTextType, boundBy: CGSize) -> CGSize {
        return textSize(for:attributedString, textAttributes:textAttributes, textType:textType, boundBy:boundBy, aligned: true)
    }
    
    func textSize(for attributedString: NSAttributedString, textAttributes: TextAttributes, textType: TargetTextType, boundBy: CGSize, aligned: Bool) -> CGSize {
        return textMetrics(for: attributedString, textAttributes: textAttributes, textType: textType, multipleLine: true, boundedBy: boundBy, aligned: aligned).viewSize
    }
    
    private func textMetrics(for attributedString: NSAttributedString, textAttributes: TextAttributes, textType: TargetTextType, multipleLine: Bool, boundedBy: CGSize, aligned: Bool) -> TextMetrics {
        
        let key = cacheKey(for: attributedString, boundedBy: boundedBy, aligned: aligned, multipleLine: multipleLine, textType: textType)
        if let result = metricsCache.object(forKey: key) {
            return result;
        }
    
        var result = TextMetrics()

        switch textType {
            case .label:
                result = textMetricsInLabel(for: attributedString, multipleLine: multipleLine, boundBy: boundedBy, aligned: aligned)
            case .field:
                result = textMetricsInTextField(for: attributedString, boundBy: boundedBy, aligned: aligned)
            case .view:
                result = textMetricsInTextView(for: attributedString, multipleLine: multipleLine, boundBy: boundedBy, aligned: aligned)
        }
    
        result.textSize.height -= textAttributes.baselineAdjustment
        metricsCache.setObject(result, forKey: key)
        return result
    }
    
    private func textMetricsInLabel(for attributedString: NSAttributedString, multipleLine: Bool, boundBy: CGSize, aligned: Bool) -> TextMetrics {
        let result = TextMetrics()
        let view = RocketLabel()
        #if !os(iOS)
        view.isBezeled = false
        #endif
        view.attributedText = attributedString
        view.numberOfLines = multipleLine ? 0 : 1
        result.textSize = view.sizeThatFits(boundBy)
        result.textSize.width = min(result.textSize.width, boundBy.width)
        result.textSize.height = min(result.textSize.height, boundBy.height)
        if aligned {
            result.textSize = CGSize(width: result.textSize.width.halfPointCeilValue, height: result.textSize.height.halfPointCeilValue)
        }
        result.viewSize = result.textSize
        return result
    }
    
    private func textMetricsInTextField(for attributedString: NSAttributedString, boundBy: CGSize, aligned: Bool) -> TextMetrics {
        let result = TextMetrics()
        let view = RocketTextField()
        view.attributedText = attributedString
        #if !os(iOS)
            view.maximumNumberOfLines = 1
        #endif
        result.textSize = view.sizeThatFits(boundBy)
        result.textSize.width = min(result.textSize.width, boundBy.width)
        result.textSize.height = min(result.textSize.height, boundBy.height)
        if aligned {
            result.textSize = CGSize(width: result.textSize.width.halfPointCeilValue, height: result.textSize.height.halfPointCeilValue)
        }
        result.viewSize = result.textSize
        return result
    }
    
    private func textMetricsInTextView(for attributedString: NSAttributedString, multipleLine: Bool, boundBy: CGSize, aligned: Bool) -> TextMetrics {
        let result = TextMetrics()
        let view = RocketTextView()
        #if os(iOS)
            let textContainer = view.textContainer
            let layoutManager = view.layoutManager
        #else
        guard let textContainer = view.textContainer else { return result }
        guard let layoutManager = view.layoutManager else { return result }
        #endif
        view.attributedText = attributedString
        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        if boundBy.width < CGFloat.greatestFiniteMagnitude {
            textContainer.size = CGSize(width: boundBy.width, height: textContainer.size.height)
        }
        if boundBy.height < CGFloat.greatestFiniteMagnitude {
            textContainer.size = CGSize(width: textContainer.size.width, height: boundBy.height)
        }
        result.viewSize = view.sizeThatFits(boundBy)
        layoutManager.ensureLayout(for: textContainer)
        result.textSize = layoutManager.usedRect(for: textContainer).size
        #if os(iOS)
            result.viewInsets = view.textContainerInset
        #endif
    
        result.textSize.width = min(result.textSize.width, boundBy.width)
        result.textSize.height = min(result.textSize.height, boundBy.height)

        if aligned {
            result.viewSize = CGSize(width: result.viewSize.width.halfPointCeilValue, height: result.viewSize.height.halfPointCeilValue)
            result.textSize = CGSize(width: result.textSize.width.halfPointCeilValue, height: result.textSize.height.halfPointCeilValue)
        }
        
        return result
    }
}

fileprivate class TextMetrics: NSObject {
    var viewSize: CGSize
    var textSize: CGSize
    var viewInsets: UIEdgeInsets
    init(viewSize: CGSize = .zero, textSize: CGSize = .zero, viewInsets: UIEdgeInsets = UIEdgeInsets.zero) {
        self.viewSize = viewSize
        self.textSize = textSize
        self.viewInsets = viewInsets
    }
}
