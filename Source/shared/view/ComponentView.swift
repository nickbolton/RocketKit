//
//  ComponentView.swift
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

@objc public protocol ComponentView {
    var isRootView: Bool { get set }
    var view: RocketBaseView { get }
    var contentView: RocketBaseView { get }
    var component: RocketComponent? { get set }
    var layoutProvider: LayoutProvider? { get set }
    func applyComponentProperties()
    func applyTextProperties()
    func updateView()
    func updateText()
}

//extension ComponentView where Self: RocketBaseView {
//}

protocol TextHavingView {
    var view: RocketBaseView { get }
    var textDescriptor: CompositeTextDescriptor? { get set }
    var textSize: CGSize { get set }
}

//extension TextHavingView where Self: RocketBaseView {
//}

