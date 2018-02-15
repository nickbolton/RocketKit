// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PBContainer8ViewController.swift instead.

import UIKit
import RocketKit

class _PBContainer8ViewController: UIViewController {

    private var componentView: ComponentView?
    var component: RocketComponent? { return componentView?.component }

    override func loadView() {
        componentView = LayoutProvider.shared.buildView(withIdentifier: "5BA80577-5D38-4B37-89C4-5B4DD327F2C7")
        didLoadRocketComponent()
        componentView?.isRootView = true
        componentView?.layoutProvider = LayoutProvider.shared
        view = componentView?.view ?? RocketView()
    }

    open func didLoadRocketComponent() {
    }
}
