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
    
    public override func copy() -> Any {
        var result = TextDescriptor(text: text)
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
