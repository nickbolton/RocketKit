//
//  LayoutEngine.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

class LayoutEngine: NSObject {

    func resolveTopLevelFrames(_ component: RocketComponent, with size: CGSize, completion: (()->Void)? = nil) {
        guard component.isTopLevelComponent, size.width > 0.0, size.height > 0.0 else {
            completion?()
            return
        }
//        component.calculatedFrame = CGRect(origin: .zero, size: size)
        
    }
}
