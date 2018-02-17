//
//  RootViewController.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/3/18.
//

import Cocoa

open class RootViewController: RocketViewController {
    
    open override func loadView() {
        componentId = LayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
