//
//  NSTextView+Rocket.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/14/18.
//

import Foundation

public extension NSTextView {
    public var attributedText: NSAttributedString {
        get { return attributedString() }
        set {
            string = ""
            textStorage?.append(newValue)
        }
    }
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let textContainer = textContainer else { return .zero }
        layoutManager?.ensureLayout(for: textContainer)
        return layoutManager?.usedRect(for: textContainer).size ?? .zero
    }
}
