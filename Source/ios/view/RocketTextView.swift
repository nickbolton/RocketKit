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
}
