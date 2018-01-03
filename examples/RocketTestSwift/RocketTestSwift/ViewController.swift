//
//  ViewController.swift
//  RocketTestSwift
//
//  Created by Nick Bolton on 5/7/17.
//  Copyright © 2017 Pixelbleed LLC. All rights reserved.
//

import UIKit
import RocketKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = RocketLayoutProvider.shared.buildViewController(withIdentifier: "542EA130-F283-494A-92DD-1BD57C8F072C")
        addChildViewController(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParentViewController: self)
    }
}

