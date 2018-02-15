// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to PBContainer6ViewController.swift instead.

import Cocoa
import RocketKit

class _PBContainer6ViewController: NSViewController {

    private var componentView: ComponentView?
    var component: RocketComponent? { return componentView?.component }

    override func loadView() {
        componentView = LayoutProvider.shared.buildView(withIdentifier: "DB84DAEA-CA05-49F7-83AA-22A72869A6E5")
        didLoadRocketComponent()
        componentView?.isRootView = true
        componentView?.layoutProvider = LayoutProvider.shared
        view = componentView?.view ?? RocketView()
    }

    open func didLoadRocketComponent() {
    }
}
