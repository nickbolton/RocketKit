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

    public func labelTextFrameWith(textDescriptor: TextDescriptor) -> CGRect {
        guard let component = component else { return .zero }
        return textDescriptor.textFrame(textType: .label, boundBy: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), usePreciseTextAlignments: component.usePreciseTextAlignments, componentFrame: frame)
    }
}
