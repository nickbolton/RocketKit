//
//  RocketLayer.swift
//  RocketKit
//
//  Created by Nick Bolton on 2/17/18.
//

import Cocoa

protocol RocketLayerDelegate: class {
    var isLayerClipped: Bool { get }
}

class RocketLayer: CALayer {

    weak var rocketDelegate: RocketLayerDelegate?
    
    override var masksToBounds: Bool {
        get { return rocketDelegate?.isLayerClipped ?? false }
        set {}
    }
}
