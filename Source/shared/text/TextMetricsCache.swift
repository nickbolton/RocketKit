//
//  AMTextMetricsCache.swift
//  Rocket
//
//  Created by Nick Bolton on 2/24/18.
//

import Cache

#if os(iOS)
    import UIKit
    typealias AMFont = UIFont
    typealias AMView = UIView
#else
    import Cocoa
    typealias AMFont = NSFont
    typealias AMView = NSView
    typealias UITextField = NSTextField
    public typealias UIEdgeInsets = NSEdgeInsets
    
    public extension UIEdgeInsets {
        static var zero: UIEdgeInsets { return UIEdgeInsets() }
    }

#endif

fileprivate let testString = "H"

@objc @objcMembers public class TextMetrics: NSObject, Codable {
    public var textSize = CGSize.zero
    public var textMargins = UIEdgeInsets.zero
    public var viewInsets = UIEdgeInsets.zero
    
    public override init() {
        super.init()
    }
    
    convenience public init(textSize: CGSize, textMargins: UIEdgeInsets, viewInsets: UIEdgeInsets) {
        self.init()
        self.textSize = textSize
        self.textMargins = textMargins
        self.viewInsets = viewInsets
    }

    convenience public init(textSize: CGSize, viewInsets: UIEdgeInsets) {
        self.init()
        self.textSize = textSize
        self.viewInsets = viewInsets
    }
    
    convenience public init(textSize: CGSize) {
        self.init()
        self.textSize = textSize
    }
    
    convenience public init(textMargins: UIEdgeInsets) {
        self.init()
        self.textMargins = textMargins
    }
    
    enum CodingKeys: String, CodingKey
    {
        case textSize
        case marginsTop
        case marginsBottom
        case marginsLeft
        case marginsRight
        case insetsTop
        case insetsBottom
        case insetsLeft
        case insetsRight
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(textSize, forKey: .textSize)
        try container.encode(textMargins.top, forKey: .marginsTop)
        try container.encode(textMargins.bottom, forKey: .marginsBottom)
        try container.encode(textMargins.left, forKey: .marginsLeft)
        try container.encode(textMargins.right, forKey: .marginsRight)
        try container.encode(viewInsets.top, forKey: .insetsTop)
        try container.encode(viewInsets.bottom, forKey: .insetsBottom)
        try container.encode(viewInsets.left, forKey: .insetsLeft)
        try container.encode(viewInsets.right, forKey: .insetsRight)
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        textSize = try values.decode(CGSize.self, forKey: .textSize)
        let marginsTop = try values.decode(CGFloat.self, forKey: .marginsTop)
        let marginsBottom = try values.decode(CGFloat.self, forKey: .marginsBottom)
        let marginsLeft = try values.decode(CGFloat.self, forKey: .marginsLeft)
        let marginsRight = try values.decode(CGFloat.self, forKey: .marginsRight)
        let insetsTop = try values.decode(CGFloat.self, forKey: .insetsTop)
        let insetsBottom = try values.decode(CGFloat.self, forKey: .insetsBottom)
        let insetsLeft = try values.decode(CGFloat.self, forKey: .insetsLeft)
        let insetsRight = try values.decode(CGFloat.self, forKey: .insetsRight)
        textMargins = UIEdgeInsets(top: marginsTop, left: marginsLeft, bottom: marginsBottom, right: marginsRight)
        viewInsets = UIEdgeInsets(top: insetsTop, left: insetsLeft, bottom: insetsBottom, right: insetsRight)
    }
}

@objc @objcMembers public class TextMetricsCache: NSObject {
    
    static public let shared = TextMetricsCache()
    private let storage: Storage?

    public override init() {
        let directory = Bundle.main.bundleIdentifier ?? "Rocket"
        let diskConfig = DiskConfig(
            // The name of disk storage, this will be used as folder name within directory
            name: "textMetrics",
            maxSize: 100000,
            directory: try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true).appendingPathComponent(directory)
        )
        let memoryConfig = MemoryConfig(
            countLimit: 1000,
            totalCostLimit: 0
        )
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
        } catch {
            print(error)
            storage = nil
        }
    }
    
    private func cacheKey(for textDescriptor: TextDescriptor) -> String {
        return "\(textDescriptor.text)|\(textDescriptor.textAttributes.cacheKey)"
    }
    
    private func cacheKey(for descriptor: CompositeTextDescriptor, boundBy: CGSize) -> String {
        var descriptorKeys = [String]()
        for td in descriptor.textDescriptors {
            let key = cacheKey(for: td)
            descriptorKeys.append(key)
        }
        return "\(descriptorKeys.description)|\(boundBy)"
    }
    
    public func textMargins(for descriptorIn: CompositeTextDescriptor) -> UIEdgeInsets {
        let descriptor = descriptorIn.copy() as! CompositeTextDescriptor
        for textDescriptor in descriptor.textDescriptors {
            textDescriptor.text = testString
        }
        
        let boundBy = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let cacheKey = "margins-" + self.cacheKey(for: descriptor, boundBy: boundBy)
        
        do {
            if let result = try storage?.object(ofType: TextMetrics.self, forKey: cacheKey) {
//                print("metrics: \(result.textSize) \(result.textMargins) \(result.viewInsets)")
                return result.textMargins
            }
        } catch {
        }
        
        let calculator = TextMetricsCalculator(attributedString: descriptor.attributedString, descriptor: descriptor, boundedSize: boundBy, textType: .label)
        let result = calculator.calculate()
        try? storage?.setObject(result, forKey: cacheKey)
//        print("text margins: \(descriptorIn.compositeText)\nmetrics2: \(result.textMargins)")
        return result.textMargins
    }

    public func textMetrics(for descriptorIn: CompositeTextDescriptor, textType: TargetTextType = .label, boundBy boundByIn: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)) -> TextMetrics {
        let descriptor = descriptorIn.copy() as! CompositeTextDescriptor
        let margins = textMargins(for: descriptorIn)
        var boundBy = CGSize(width: boundByIn.width > 0 ? boundByIn.width : CGFloat.greatestFiniteMagnitude, height: boundByIn.height > 0 ? boundByIn.height : CGFloat.greatestFiniteMagnitude)
        if boundByIn.width > 0 {
            boundBy.width += margins.left + margins.right
        }
        
        let cacheKey = self.cacheKey(for: descriptor, boundBy: boundBy)
        do {
            if let result = try storage?.object(ofType: TextMetrics.self, forKey: cacheKey) {
//                print("metrics: \(result.textSize) \(result.textMargins) \(result.viewInsets)")
                return result
            }
        } catch {
        }
        
        let calculator = TextMetricsCalculator(attributedString: descriptor.attributedString, descriptor: descriptor, boundedSize: boundBy, textType: textType)
        let result = calculator.calculate()
        
        try? storage?.setObject(result, forKey: cacheKey)
//        print("text: \(descriptorIn.compositeText)\nmetrics2: \(result.textSize) \(result.textMargins) \(result.viewInsets)")
        return result
    }
}

class TextMetricsCalculator: NSObject, NSLayoutManagerDelegate {
    var attributedString: NSAttributedString
    let descriptor: CompositeTextDescriptor
    let boundedSize: CGSize
    let textType: TargetTextType
    var storage: Storage?

    required init(attributedString: NSAttributedString, descriptor: CompositeTextDescriptor, boundedSize: CGSize, textType: TargetTextType) {
        self.attributedString = attributedString
        self.descriptor = descriptor
        self.boundedSize = boundedSize
        self.textType = textType
    }
    
    private var characterFonts = [Int: AMFont]()
    private var firstGlyph: CGGlyph?
    
    func calculate() -> TextMetrics {
        let container = NSTextContainer()

        let maxFloat = min(CGFloat(MAXFLOAT), CGFloat.greatestFiniteMagnitude)
        if boundedSize.width < maxFloat {
            container.size = CGSize(width: boundedSize.width, height: container.size.height)
        }
        if boundedSize.height < maxFloat {
            container.size = CGSize(width: container.size.width, height: boundedSize.height)
        }
        
        let storage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        layoutManager.delegate = self
        
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        
        layoutManager.ensureLayout(for: container)
        let rect = layoutManager.usedRect(for: container)
        let height = rect.height + descriptor.maxAbsoluteBaselineAdjustment
        let size = CGSize(width: round(rect.width * 2.0) / 2.0, height: round(height * 2.0) / 2.0)

        let metrics = TextMetrics(textSize: size)
        
        if attributedString.length <= 0 {
            let textDescriptor = descriptor.textDescriptors.first ?? TextDescriptor(text: testString)
            textDescriptor.text = testString
            attributedString = textDescriptor.attributedString
        }

        if descriptor.isMixedStyleText {
            return updateMetricsForMixedStyleText(metrics, layoutManager: layoutManager, attributedString: attributedString)
        }
        return updateMetricsForSingleStyleText(metrics)
    }
    
    func singleStyleTextMargins(for descriptorIn: TextDescriptor?, textType: TargetTextType) -> TextMetrics {
        guard let descriptorIn = descriptorIn else { return TextMetrics() }
        
        let cacheKey = self.cacheKey(for: descriptorIn)
        
        var result: TextMetrics?
        do {
            result = try storage?.object(ofType: TextMetrics.self, forKey: cacheKey)
            if let result = result {
                return result
            }
        } catch {
        }
        
        var glyph = [CGGlyph](repeating: 0, count: 1)
        var glyphRects = [CGRect](repeating: .zero, count: 1)
        
        let font = descriptorIn.textAttributes.font
        let unichars = [UniChar](testString.utf16)
        
        CTFontGetGlyphsForCharacters(font, unichars, &glyph, 1)
        CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphRects, 1)
        
        let glyphRect = glyphRects.first ?? .zero
        
        let descriptor = self.descriptor.textDescriptors.first!
        var textAttributes = descriptor.textAttributes
        textAttributes.kerning = 0.0
        descriptor.text = testString
        descriptor.textAttributes = textAttributes
        
        let textMetrics = self.textMetrics(for: descriptor, descriptor: self.descriptor, textType: textType)
        if textMetrics.textSize == .zero {
            return TextMetrics()
        }
        
        let alignedWidth = ceil(textMetrics.textSize.width * 2.0) / 2.0
        let alignedHeight = ceil(textMetrics.textSize.height * 2.0) / 2.0
        let alignedSize = CGSize(width: alignedWidth, height: alignedHeight)
        
        var horizontalMargins = floor(alignedSize.width - glyphRect.width)
        horizontalMargins /= 2.0
        
        var insets = UIEdgeInsets.zero
        insets.left = horizontalMargins
        insets.right = horizontalMargins
        
        let glyphHeight = ceil(glyphRect.height * 2.0) / 2.0
        let verticalSpacing = textMetrics.textSize.height - glyphHeight - descriptor.textAttributes.totalBaselineOffset
        
        var bottom = abs(font.descender) - descriptor.textAttributes.totalBaselineOffset
        if textType == .view {
            bottom += font.leading
        }
        
        #if os(iOS)
        insets.bottom = max((floor(bottom * 2.0) / 2.0) - textMetrics.viewInsets.bottom, 0.0)
        insets.top = verticalSpacing - insets.bottom
        insets.top = ceil(insets.top * 2.0) / 2.0
        #else
        insets.bottom = max(round(bottom) - textMetrics.viewInsets.bottom, 0.0)
        insets.top = verticalSpacing - insets.bottom
        insets.top = round(insets.top * 2.0) / 2.0
        #endif
        
        result = TextMetrics(textMargins: insets)
        try? storage?.setObject(result!, forKey: cacheKey)
        return result!
    }
    
    private func updateMetricsForSingleStyleText(_ metrics: TextMetrics) -> TextMetrics {
        let margins = singleStyleTextMargins(for: descriptor.textDescriptors.first, textType: textType)
        return TextMetrics(textSize: metrics.textSize, textMargins: margins.textMargins, viewInsets: metrics.viewInsets)
    }
    
    private func updateMetricsForMixedStyleText(_ metrics: TextMetrics, layoutManager: NSLayoutManager, attributedString: NSAttributedString) -> TextMetrics {
        
        guard characterFonts.count >= attributedString.length else { return metrics }
        
        var bottomLocation = -CGFloat.greatestFiniteMagnitude
        var topLocation = CGFloat.greatestFiniteMagnitude
        
        var rects = [CGRect]()
        
        for i in 0..<attributedString.length {
            let charRange = NSMakeRange(i, 1)
            var rect = CGRect.zero
            layoutManager.enumerateEnclosingRects(forGlyphRange: charRange, withinSelectedGlyphRange: charRange, in: layoutManager.textContainers.first!, using: { (r, _) in
                rect = r
            })
            rects.append(rect)
            bottomLocation = max(bottomLocation, rect.minY)
            topLocation = min(topLocation, rect.minY)
        }
    
        var minTopIndex = Int.max
        var maxTopIndex = 0
        var minBottomIndex = Int.max
        var maxBottomIndex = 0

        var firstCharCapHeight: CGFloat = 0.0
        var firstBottomCharBottom: CGFloat = 0.0
        
        var topRect = CGRect.zero
        
        for i in 0..<attributedString.length {
            let font = characterFonts[i]!
            let baseline = abs(font.descender) + font.leading
            
            guard i < rects.count else { continue }
            
            let rect = rects[i]
            if rect.minY == topLocation {
                minTopIndex = min(minTopIndex, i)
                maxTopIndex = max(maxTopIndex, i)
                if firstCharCapHeight == 0.0 {
                    firstCharCapHeight = baseline + font.capHeight
                    topRect = rect
                }
            }
            
            if rect.minY == bottomLocation {
                minBottomIndex = min(minBottomIndex, i)
                maxBottomIndex = max(maxBottomIndex, i)
                if firstBottomCharBottom == 0.0 {
                    firstBottomCharBottom = baseline
                }
            }
        }

        let font = characterFonts[0]!
    
        var top = topRect.height - firstCharCapHeight
        top = floor(top)

        let result = TextMetrics(textSize: metrics.textSize, textMargins: UIEdgeInsets(top: top, left: 0.0, bottom: firstBottomCharBottom, right: 0.0), viewInsets: metrics.viewInsets)
        return updateHorizontalInsets(result, with: font)
    }
    
    private func updateHorizontalInsets(_ metrics: TextMetrics, with font: AMFont) -> TextMetrics {
    
        var glyph = [CGGlyph](repeating: 0, count: 1)
        var glyphRects = [CGRect](repeating: .zero, count: 1)
        
        let unichars = [UniChar](testString.utf16)
        
        CTFontGetGlyphsForCharacters(font, unichars, &glyph, 1)
        CTFontGetBoundingRectsForGlyphs(font, .default, &glyph, &glyphRects, 1)
        
        let glyphRect = glyphRects.first ?? .zero

        let descriptor = self.descriptor.textDescriptors.first!
        var textAttributes = descriptor.textAttributes
        textAttributes.kerning = 0.0
        descriptor.text = testString
        descriptor.textAttributes = textAttributes
        
        let textMetrics = self.textMetrics(for: descriptor, descriptor: self.descriptor, textType: textType)
        if textMetrics.textSize == .zero {
            return metrics
        }
    
        let alignedWidth = ceil(textMetrics.textSize.width * 2.0) / 2.0
        let alignedHeight = ceil(textMetrics.textSize.height * 2.0) / 2.0
        let alignedSize = CGSize(width: alignedWidth, height: alignedHeight)
    
        var horizontalMargins = floor(alignedSize.width - glyphRect.width)
        horizontalMargins /= 2.0
    
        var margins = metrics.textMargins
        margins.left = horizontalMargins
        margins.right = horizontalMargins
        return TextMetrics(textSize: metrics.textSize, textMargins: margins, viewInsets: metrics.viewInsets)
    }
    
    private func cacheKey(for textDescriptor: TextDescriptor) -> String {
        return "side-margins-\(textDescriptor.text)|\(textDescriptor.textAttributes.cacheKey)"
    }
    
    private func textMetrics(for textDescriptor: TextDescriptor, descriptor: CompositeTextDescriptor, textType: TargetTextType) -> TextMetrics {
    
        let cacheKey = self.cacheKey(for: textDescriptor)
        
        var result: TextMetrics?
        do {
            result = try storage?.object(ofType: TextMetrics.self, forKey: cacheKey)
            if let result = result {
                return result
            }
        } catch {
        }
                
        let attributedString = textDescriptor.attributedString
    
        switch textType {
        case .label:
            result = textMetricsInLabel(for: attributedString)
        case .field:
            result = textMetricsInTextField(for: attributedString)
        case .view:
            result = textMetricsInTextView(for: attributedString)
        }
    
        var textSize = result!.textSize
        textSize.height -= descriptor.baselineAdjustment
        result = TextMetrics(textSize: textSize, viewInsets: result!.viewInsets)
    
        try? storage?.setObject(result!, forKey: cacheKey)
        return result!
    }
    
    private func textMetricsInLabel(for attributedString: NSAttributedString) -> TextMetrics {
        let view = UILabel()
        view.attributedText = attributedString
        view.numberOfLines = 1
        let size = view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        return TextMetrics(textSize: size)
    }

    private func textMetricsInTextField(for attributedString: NSAttributedString) -> TextMetrics {
        let view = UITextField()
        view.attributedText = attributedString
        let size = view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        return TextMetrics(textSize: size)
    }

    private func textMetricsInTextView(for attributedString: NSAttributedString) -> TextMetrics {
        let result = TextMetrics()
        let view = UITextView()
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
        layoutManager.ensureLayout(for: textContainer)
        let size = layoutManager.usedRect(for: textContainer).size
        var viewInsets = UIEdgeInsets.zero
        #if os(iOS)
            viewInsets = view.textContainerInset
        #endif
        return TextMetrics(textSize: size, viewInsets: viewInsets)
    }
    
    // MARK: NSLayoutManagerDelegate Conformance
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: AMFont, forGlyphRange glyphRange: NSRange) -> Int {
        for idx in 0..<glyphRange.length {
            characterFonts[charIndexes[idx]] = aFont
            if charIndexes[idx] == 0 {
                firstGlyph = glyphs[idx]
            }
        }
        return 0;
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldSetLineFragmentRect lineFragmentRect: UnsafeMutablePointer<CGRect>, lineFragmentUsedRect: UnsafeMutablePointer<CGRect>, baselineOffset: UnsafeMutablePointer<CGFloat>, in textContainer: NSTextContainer, forGlyphRange glyphRange: NSRange) -> Bool {
        
        var offset: CGFloat = 0.0
        
        attributedString.enumerateAttributes(in: NSMakeRange(0, attributedString.length), options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (attrs, _, _) in
            if let offsetValue = attrs[NSBaselineOffsetAttributeName] as? CGFloat, offsetValue < 0.0 {
                offset = min(offset, offsetValue)
            }
        }
        
        if offset != 0.0 {
            baselineOffset.pointee -= offset
        }
        
        return true
    }
}
