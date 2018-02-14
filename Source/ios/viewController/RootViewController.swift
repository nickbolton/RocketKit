//
//  RootViewController.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/8/17.
//
//

import UIKit

public class RootViewController: RocketViewController {

    public override func loadView() {
        componentId = LayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
