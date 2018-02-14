//
//  RocketTypes.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
    
    public typealias RocketBaseView = UIView
    typealias RocketLabel = UILabel
    typealias RocketTextField = UITextField
    typealias RocketTextView = UITextView
#else
    import Cocoa
    
    typealias UIEdgeInsets = NSEdgeInsets

    public typealias RocketBaseView = NSView
    typealias RocketLabel = NSTextField
    typealias RocketTextField = NSTextField
    typealias RocketTextView = NSTextView
#endif

typealias FailureHandler = ((Error?)->Void)

public enum TextAlignment : Int {
    case left // Visually left aligned
    case center // Visually centered
    case right // Visually right aligned
    case justified // Fully-justified. The last line in a paragraph is natural-aligned.
    case natural // Indicates the default alignment for script
    
    func nativeAlignment() -> NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        case .justified:
            return .justified
        case .natural:
            return .natural
        }
    }
}
