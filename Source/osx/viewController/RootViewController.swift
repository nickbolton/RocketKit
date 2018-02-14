//
//  RootViewController.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/3/18.
//

import Cocoa

public class RootViewController: RocketViewController {
    
    public override func loadView() {
        componentId = LayoutProvider.shared.layoutSource?.rootComponentId
        super.loadView()
    }
}
