//
//  RocketLayoutMeta.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/5/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public enum RocketLayoutState: Int {
    case disabled
    case def
    case low
    case notRequired
    case required
}

public enum RocketMetaType: Int {
    case none
    case ideal
    case min
    case max
}

public class RocketLayoutMeta: RocketBaseObject {
    
    let constant: CGFloat
    let multiplier: CGFloat
    let proportionalLayoutObjectIdentifier: String?
    let proportionalAttribute: NSLayoutAttribute
    let layoutState: RocketLayoutState
    let metaType: RocketMetaType
    
    var isProportional: Bool { return multiplier != 0.0 && proportionalLayoutObjectIdentifier != nil }
    var isActive: Bool { return layoutState != .disabled }
    var isLowerPriority: Bool { return layoutState == .low }

    private static let constantKey = "constant"
    private static let multiplierKey = "multiplier"
    private static let proportionalLayoutObjectIdentifierKey = "proportionalLayoutObjectIdentifier"
    private static let proportionalAttributeKey = "proportionalAttribute"
    private static let stateKey = "state"
    private static let typeKey = "type"
    
    required public init(dictionary: [String: Any], layoutSource: RocketLayoutSource) {
        self.constant = CGFloat(dictionary[RocketLayoutMeta.constantKey] as? Float ?? 0.0)
        self.multiplier = CGFloat(dictionary[RocketLayoutMeta.multiplierKey] as? Float ?? 0.0)
        self.proportionalLayoutObjectIdentifier = dictionary[RocketLayoutMeta.proportionalLayoutObjectIdentifierKey] as? String
        self.proportionalAttribute = NSLayoutAttribute(rawValue: dictionary[RocketLayoutMeta.proportionalAttributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.layoutState = RocketLayoutState(rawValue: dictionary[RocketLayoutMeta.stateKey] as? Int ?? 0) ?? .disabled
        self.metaType = RocketMetaType(rawValue: dictionary[RocketLayoutMeta.typeKey] as? Int ?? 0) ?? .none
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
}
