//
//  RocketLabel+Rocket.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/14/18.
//

import Foundation

public extension RocketLabel {
    public var attributedText: NSAttributedString {
        get { return attributedStringValue }
        set { attributedStringValue = newValue }
    }
    public var numberOfLines: Int {
        get { return maximumNumberOfLines }
        set { maximumNumberOfLines = newValue }
    }
}
