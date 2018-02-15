// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PBContainer15ViewController.swift instead.

import UIKit
import RocketKit

class _PBContainer15ViewController: UIViewController {

    private var componentView: ComponentView?
    var component: RocketComponent? { return componentView?.component }

    override func loadView() {
        componentView = LayoutProvider.shared.buildView(withIdentifier: "4EB71825-C7B1-45AD-8ACA-067F7EE7F55F")
        didLoadRocketComponent()
        componentView?.isRootView = true
        componentView?.layoutProvider = LayoutProvider.shared
        view = componentView?.view
    }

    open func didLoadRocketComponent() {
    }
}
