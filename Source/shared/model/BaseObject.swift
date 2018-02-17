//
//  BaseObject.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Foundation

public class BaseObject: NSObject {

    public let identifier: String
    
    private static let identifierKey = "identifier"
    
    required public init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.identifier = dictionary[BaseObject.identifierKey] as? String ?? ""
        super.init()
    }
}
