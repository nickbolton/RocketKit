//
//  RocketBaseObject.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Foundation

public class RocketBaseObject: NSObject {

    let identifier: String
    
    private static let identifierKey = "identifier"
    
    required public init(dictionary: [String: Any], layoutSource: RocketLayoutSource) {
        self.identifier = dictionary[RocketBaseObject.identifierKey] as? String ?? ""
        super.init()
    }
}
