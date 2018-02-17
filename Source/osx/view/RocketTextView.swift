//
//  RocketTextView.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import Cocoa

class RocketTextView: NSTextView, TextHavingView {
    var view: RocketBaseView { return self }
    
    var textDescriptor: TextDescriptor? {
        didSet {
            typingAttributes = textDescriptor?.textAttributes.attributes ?? [:]
            attributedText = textDescriptor?.attributedString ?? NSAttributedString()
        }
    }
    
    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        _commonInit()
    }
    
    private func _commonInit() {
        isEditable = true
        isSelectable = true
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
