// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PBContainer25ViewController.swift instead.

import UIKit
import RocketKit

class _PBContainer25ViewController: UIViewController {

    private var componentView: ComponentView?
    var component: RocketComponent? { return componentView?.component }

    override func loadView() {
        componentView = LayoutProvider.shared.buildView(withIdentifier: "9CB96738-8FC1-4B89-B5F8-2A199FC40807")
        didLoadRocketComponent()
        componentView?.isRootView = true
        componentView?.layoutProvider = LayoutProvider.shared
        view = componentView?.view ?? RocketView()
    }

    open func didLoadRocketComponent() {
    }
}
