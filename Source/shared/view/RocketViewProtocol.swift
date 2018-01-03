//
//  RocketViewProtocol.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public protocol RocketViewProtocol {
    var isRootView: Bool { get set }
    var view: RocketBaseView { get }
    var component: RocketComponent? { get set }
    var layoutProvider: RocketLayoutProvider? { get set }
    func applyComponentProperties()
}
