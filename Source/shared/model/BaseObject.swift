//
//  BaseObject.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

import Foundation

protocol Exportable {
    func dictionaryRepresentation() -> [String: Any]
}

protocol Importable {
    init(dictionary: [String: Any])
}

public class BaseObject: NSObject, Exportable, Importable {

    public let identifier: String
    
    private let identifierKey = "identifier"
    
    required public override init() {
        self.identifier = UUID().uuidString
    }
    
    required public init(dictionary: [String: Any]) {
        self.identifier = dictionary[identifierKey] as? String ?? ""
        super.init()
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        return [identifierKey : identifier]
    }
}
