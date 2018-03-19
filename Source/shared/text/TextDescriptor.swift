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

public class TextDescriptor: NSObject {
    
    public var text = ""
    public var textAttributes = TextAttributes()
    public var textRange = NSMakeRange(0, 0)
    public var compositeTextRange = NSMakeRange(0, 0)
    
    fileprivate let textKey = "text"
    fileprivate let textAttributesKey = "textAttributes"
    
    public static var defaultTextDescriptor: TextDescriptor { return TextDescriptor(text: "") }
    
    public var attributedString: NSAttributedString { return NSAttributedString(string: text, attributes: textAttributes.attributes) }
    public var attributes: [String: Any] { return textAttributes.attributes }
    
    public init(dictionary: [String: Any]) {
        self.text = dictionary[textKey] as? String ?? ""
        if let attributesDict = dictionary[textAttributesKey] as? [String: Any] {
            self.textAttributes = TextAttributes(dictionary: attributesDict)
        }
    }
    
    public init(text: String) {
        self.text = text
    }
    
    public init(text: String,
                font: UIFont,
                textColor: UIColor = .clear,
                lineHeight: CGFloat? = nil,
                kerning: CGFloat = 0.0,
                paragraphSpacing: CGFloat = 0.0,
                baselineOffset: CGFloat = 0.0,
                textAlignment: TextAlignment = .left,
                verticalAlignment: TextVerticalAlignment = .center,
                lineBreakMode: NSLineBreakMode = .byWordWrapping,
                isUnderline: Bool = false) {
        self.text = text
        self.textAttributes = TextAttributes(font: font, textColor: textColor, lineHeight: lineHeight, kerning: kerning, paragraphSpacing: paragraphSpacing, baselineOffset: baselineOffset, textAlignment: textAlignment, verticalAlignment: verticalAlignment, lineBreakMode: lineBreakMode, isUnderline: isUnderline)
    }
    
    public override func copy() -> Any {
        let result = TextDescriptor(text: text)
        result.textAttributes = textAttributes
        return result
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        let textAttributes = self.textAttributes
        var dict = [String: Any]()
        dict[textAttributesKey] = textAttributes
        dict[textKey] = text
        return dict
    }
}
