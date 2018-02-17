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

    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
