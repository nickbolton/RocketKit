//
//  RocketTextDescriptor+Measurements.swift
//  Pods-RocketTestSwift
//
//  Created by Nick Bolton on 1/3/18.
//

import Foundation

extension RocketTextDescriptor {
    func textSizeInLabel(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = UILabel()
        view.attributedText = attributedString
        view.numberOfLines = 0
        let size = view.sizeThatFits(boundBy)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func textSizeInTextField(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = UITextField()
        view.attributedText = attributedString
        let size = view.sizeThatFits(boundBy)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func textSizeInTextView(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = UITextView()
        view.attributedText = attributedString
        view.textContainer.widthTracksTextView = false
        view.textContainer.heightTracksTextView = false
        let maxValue = min(CGFloat.greatestFiniteMagnitude, CGFloat(MAXFLOAT))
        if boundBy.width < maxValue {
            view.textContainer.size = CGSize(width: view.textContainer.size.width, height: boundBy.height)
        }
        if boundBy.height < maxValue {
            view.textContainer.size = CGSize(width: boundBy.width, height: view.textContainer.size.height)
        }
        view.layoutManager.ensureLayout(for: view.textContainer)
        let frame = view.layoutManager.usedRect(for: view.textContainer)
        return CGSize(width: ceil(frame.width), height: ceil(frame.height))
    }
}
