//
//  RocketRootViewController.swift
//  Pods
//
//  Created by Nick Bolton on 5/8/17.
//
//

import UIKit

public class RocketRootViewController: RocketViewController {

    public override func loadView() {
        componentId = RocketLayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
