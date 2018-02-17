//
//  RocketLabel.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import UIKit

class RocketLabel: UILabel, TextHavingView {
    var view: RocketBaseView { return self }
    var attributedString: NSAttributedString? {
        get { return attributedText }
        set { attributedText = newValue }
    }
    
    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }

    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
