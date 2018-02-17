//
//  RocketTextView.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import UIKit

class RocketTextView: UITextView, TextHavingView {
    var view: RocketBaseView { return self }
    var attributedString: NSAttributedString? {
        get { return attributedText }
        set { attributedText = newValue ?? NSAttributedString()}
    }
    
    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
