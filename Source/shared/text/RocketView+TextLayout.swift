//
//  RocketView+TextLayout.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public extension RocketView {

    public func labelTextFrameWith(textDescriptor: RocketTextDescriptor) -> CGRect {
        guard let label = label else { return .zero }
        return textDescriptor.textFrame(boundBy: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude),
                                        componentFrame: frame,
                                        textView: label)
    }
}
