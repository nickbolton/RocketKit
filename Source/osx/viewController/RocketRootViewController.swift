//
//  RocketRootViewController.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/3/18.
//

import Cocoa

public class RocketRootViewController: RocketViewController {
    
    public override func loadView() {
        componentId = RocketLayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
