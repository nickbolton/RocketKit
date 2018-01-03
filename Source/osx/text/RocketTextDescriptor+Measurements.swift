//
//  RocketTextDescriptor+Measurements.swift
//  Pods-RocketTestMacSwift
//
//  Created by Nick Bolton on 1/3/18.
//

import Foundation

extension RocketTextDescriptor {
    func textSizeInLabel(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = NSTextField()
        view.isBezeled = false
        view.isEditable = false
        view.attributedStringValue = attributedString
        view.maximumNumberOfLines = 0
        let size = view.sizeThatFits(boundBy)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func textSizeInTextField(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = NSTextField()
        view.isBezeled = false
        view.attributedStringValue = attributedString
        let size = view.sizeThatFits(boundBy)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    func textSizeInTextView(for attributedString: NSAttributedString, boundBy: CGSize) -> CGSize {
        let view = NSTextView()
        view.string = ""
        view.textStorage?.append(attributedString)
        
        view.textContainer?.widthTracksTextView = false
        view.textContainer?.heightTracksTextView = false
        let maxValue = min(CGFloat.greatestFiniteMagnitude, CGFloat(MAXFLOAT))
        if boundBy.width < maxValue {
            view.textContainer?.size = CGSize(width: view.textContainer?.size.width ?? 0, height: boundBy.height)
        }
        if boundBy.height < maxValue {
            view.textContainer?.size = CGSize(width: boundBy.width, height: view.textContainer?.size.height ?? 0)
        }
        if view.textContainer != nil {
            view.layoutManager?.ensureLayout(for: view.textContainer!)
            if let frame = view.layoutManager?.usedRect(for: view.textContainer!) {
                return CGSize(width: ceil(frame.width), height: ceil(frame.height))
            }
        }
        return .zero
    }
}
