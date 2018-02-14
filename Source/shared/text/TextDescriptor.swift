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

public struct TextDescriptor {
    
    public var text = ""
    public var textAttributes = TextAttributes()
    
    private static let textKey = "text"
    private static let textAttributesKey = "textAttributes"
    
    public var attributedString: NSAttributedString {
        return NSAttributedString(string: text, attributes: textAttributes.attributes)
    }

    public init(dictionary: [String: Any]) {
        self.text = dictionary[TextDescriptor.textKey] as? String ?? ""
        if let attributesDict = dictionary[TextDescriptor.textAttributesKey] as? [String: Any] {
            self.textAttributes = TextAttributes(dictionary: attributesDict)
        }
    }
    
    public func containerFrame(for text: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool) -> CGRect {
        let (containerFrame, _) = textAndContainerFrames(for: text, textType: textType, boundBy: boundBy, usePreciseTextAlignments: usePreciseTextAlignments, componentFrame: .zero)
        return containerFrame
    }

    public func textFrame(for text: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool, componentFrame: CGRect) -> CGRect {
        let (_, textFrame) = textAndContainerFrames(for: text, textType: textType, boundBy: boundBy, usePreciseTextAlignments: usePreciseTextAlignments, componentFrame: componentFrame)
        return textFrame
    }
    
    public func textAndContainerFrames(for textIn: String? = nil, textType: TargetTextType, boundBy: CGSize, usePreciseTextAlignments: Bool, componentFrame: CGRect) -> (CGRect, CGRect) {
        
        let text = textIn ?? self.text
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

        let maxValue = CGFloat.greatestFiniteMagnitude
        let width = boundBy.width < maxValue ? boundBy.width: size.width
        let height = (boundBy.height < maxValue ? boundBy.height : size.height) - textAttributes.baselineAdjustment

        let sideMargins = TextMetricsCache.shared.textMargins(for: self, textType: textType)
        let horizontalPadding = sideMargins.left + sideMargins.right
        let verticalPadding = sideMargins.top + sideMargins.bottom

        let containerSize = CGSize(width: width.halfPointCeilValue, height: height.halfPointCeilValue)
        var containerFrame = CGRect.zero
        containerFrame.size = containerSize
        if usePreciseTextAlignments {
            containerFrame.size.width -= horizontalPadding
            containerFrame.size.height -= verticalPadding
        }
        containerFrame.size.height = containerFrame.height.halfPointRoundValue

        var textFrame = CGRect.zero

        if usePreciseTextAlignments {
            textFrame = CGRect(x: -sideMargins.left, y: 0.0, width: size.width, height: size.height)
            if textAttributes.textAlignment == .center || textAttributes.textAlignment == .justified {
                textFrame.origin.x = -(sideMargins.left + sideMargins.right) / 2.0
            }
        } else {
            textFrame = containerFrame
        }

        let heightDiff = componentFrame.height - size.height

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

public enum TargetTextType {
    case label
    case field
    case view
}

struct TextMetricsCache {
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
        
        let testString = "H"
        
        let font = descriptorIn.textAttributes.font
        let unichars = [UniChar](testString.utf16)
        
        CTFontGetGlyphsForCharacters(font, unichars, &glyph, 1)
        CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphRects, 1)
        
        let glyphRect = glyphRects.first ?? .zero
        
        var descriptor = descriptorIn
        descriptor.text = testString
        descriptor.textAttributes.kerning = 0.0
        
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
                result = textMetricsInTextField(for: attributedString, multipleLine: multipleLine, boundBy: boundedBy, aligned: aligned)
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
        view.attributedText = attributedString;
        view.numberOfLines = multipleLine ? 0 : 1;
        result.textSize = view.sizeThatFits(boundBy)
        if aligned {
            result.textSize = CGSize(width: result.textSize.width.halfPointCeilValue, height: result.textSize.height.halfPointCeilValue)
        }
        result.viewSize = result.textSize
        return result
    }
    
    private func textMetricsInTextField(for attributedString: NSAttributedString, multipleLine: Bool, boundBy: CGSize, aligned: Bool) -> TextMetrics {
        let result = TextMetrics()
        let view = RocketTextField()
        view.attributedText = attributedString
        #if !os(iOS)
            view.numberOfLines = multipleLine ? 0 : 1
        #endif
        result.textSize = view.sizeThatFits(boundBy)
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
