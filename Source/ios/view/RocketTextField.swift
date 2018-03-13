//
//  RocketTextField.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import UIKit

class RocketTextField: UITextField, TextHavingView {
    var view: RocketBaseView { return self }
    var textDescriptor: CompositeTextDescriptor? { didSet { attributedText = textDescriptor?.attributedString } }

    var textSize: CGSize = .zero
    override var intrinsicContentSize: CGSize { return textSize }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
