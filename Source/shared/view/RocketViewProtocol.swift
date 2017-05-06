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
    import AppKit
#endif

@objc public protocol RocketViewProtocol {
    var isRootView: Bool { get set }
    var view: BaseView { get }
    var component: Component? { get set }
    var layoutProvider: LayoutProvider? { get set }
    func applyComponentProperties()
}
