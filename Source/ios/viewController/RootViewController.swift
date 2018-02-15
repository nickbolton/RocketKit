//
//  RootViewController.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/8/17.
//
//

import UIKit

open class RootViewController: RocketViewController {
    open override func loadView() {
        componentId = LayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
