//
//  RocketTextField.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import Cocoa

class RocketTextField: NSTextField, TextHavingView {
    var view: RocketBaseView { return self }
    var textDescriptor: TextDescriptor? {
        didSet {
            font = textDescriptor?.textAttributes.font
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
    
    public override var wantsDefaultClipping: Bool { return false }
    
    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        maximumNumberOfLines = 1
        isBezeled = false
        isEditable = true
        isSelectable = true
        focusRingType = .none
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
