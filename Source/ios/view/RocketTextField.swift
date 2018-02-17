//
//  RocketTextField.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import UIKit

class RocketTextField: UITextField, TextHavingView {
    var view: RocketBaseView { return self }
    var attributedString: NSAttributedString? {
        get { return attributedText }
        set { attributedText = newValue }
    }
}
