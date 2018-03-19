//
//  CalculatedLayout.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/16/18.
//

import UIKit

struct CalculatedLayout {
    let layout: Layout?
    let constrainedSize: SizeRange
    let parentSize: CGSize
    let requestedLayoutFromAbove: Bool
    let version: Int

    init(layout: Layout? = nil, constrainedSize: SizeRange = .zero, parentSize: CGSize = .zero, requestedLayoutFromAbove: Bool = false, version: Int = 0) {
        self.layout = layout
        self.constrainedSize = constrainedSize
        self.parentSize = parentSize
        self.requestedLayoutFromAbove = requestedLayoutFromAbove
        self.version = version
    }
    
    func isValid(constrainedSize: SizeRange, parentSize: CGSize, version: Int) -> Bool {
        return self.version >= version
            && layout != nil
            && self.parentSize == parentSize
            && self.constrainedSize == constrainedSize
    }
}
