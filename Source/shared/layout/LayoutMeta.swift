//
//  LayoutMeta.swift
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

public enum LayoutState: Int {
    case disabled
    case def
    case low
    case notRequired
    case required
}

public enum MetaType: Int {
    case none
    case ideal
    case min
    case max
}

public class LayoutMeta: BaseObject {
    
    public var constant: CGFloat = 0.0
    public var multiplier: CGFloat = 0.0
    public var proportionalLayoutObjectIdentifier: String? = nil
    public var proportionalAttribute = NSLayoutAttribute.notAnAttribute
    public var layoutState = LayoutState.disabled
    public var metaType = MetaType.none
    
    public var isProportional: Bool { return multiplier != 0.0 && proportionalLayoutObjectIdentifier != nil }
    public var isActive: Bool { return layoutState != .disabled }
    public var isLowerPriority: Bool { return layoutState == .low }

    private static let constantKey = "constant"
    private static let multiplierKey = "multiplier"
    private static let proportionalLayoutObjectIdentifierKey = "proportionalLayoutObjectIdentifier"
    private static let proportionalAttributeKey = "proportionalAttribute"
    private static let stateKey = "state"
    private static let typeKey = "type"
    
    required public override init(dictionary: [String: Any], layoutSource: LayoutSource) {
        self.constant = CGFloat(dictionary[LayoutMeta.constantKey] as? Float ?? 0.0)
        self.multiplier = CGFloat(dictionary[LayoutMeta.multiplierKey] as? Float ?? 0.0)
        self.proportionalLayoutObjectIdentifier = dictionary[LayoutMeta.proportionalLayoutObjectIdentifierKey] as? String
        self.proportionalAttribute = NSLayoutAttribute(rawValue: dictionary[LayoutMeta.proportionalAttributeKey] as? Int ?? 0) ?? .notAnAttribute
        self.layoutState = LayoutState(rawValue: dictionary[LayoutMeta.stateKey] as? Int ?? 0) ?? .disabled
        self.metaType = MetaType(rawValue: dictionary[LayoutMeta.typeKey] as? Int ?? 0) ?? .none
        super.init(dictionary: dictionary, layoutSource: layoutSource)
    }
    
    required public override init() {
        super.init()
    }
    
    convenience public init(multipler: CGFloat = 1.0, constant: CGFloat = 0.0, metaType: MetaType = .ideal, layoutState: LayoutState = .required) {
        self.init()
        self.multiplier = multipler
        self.constant = constant
        self.metaType = metaType
        self.layoutState = layoutState
    }
}
