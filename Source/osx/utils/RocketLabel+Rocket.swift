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
        set { attributedStringValue = attributedText }
    }
    public var numberOfLines: Int {
        get { return maximumNumberOfLines }
        set { maximumNumberOfLines = numberOfLines }
    }
}
