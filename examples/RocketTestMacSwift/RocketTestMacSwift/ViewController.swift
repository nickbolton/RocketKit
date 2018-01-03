//
//  ViewController.swift
//  RocketTestMacSwift
//
//  Created by Nick Bolton on 5/7/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import Cocoa
import RocketKit

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = RocketLayoutProvider.shared.buildViewController(withIdentifier: "78595176-65AE-466F-B747-B17724C1AA17")
        addChildViewController(vc)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable.union(.viewHeightSizable)
        view.addSubview(vc.view)
    }
}

