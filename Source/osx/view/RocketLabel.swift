//
//  RocketLabel.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import Cocoa

class RocketLabel: NSTextField, TextHavingView {
    var view: RocketBaseView { return self }
    var textDescriptor: TextDescriptor? {
        didSet {
            attributedStringValue = textDescriptor?.attributedString ?? NSAttributedString()
        }
    }
    
    public var attributedText: NSAttributedString {
        get { return attributedStringValue }
        set { attributedStringValue = newValue }
    }
    public var numberOfLines: Int {
        get { return maximumNumberOfLines }
        set { maximumNumberOfLines = newValue }
    }
        
    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        maximumNumberOfLines = 0
        isBezeled = false
        isEditable = false
        isSelectable = false
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
