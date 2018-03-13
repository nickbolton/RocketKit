//
//  RocketTypes.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
    
    public typealias RocketBaseView = UIView
#else
    import Cocoa
    
    typealias UIEdgeInsets = NSEdgeInsets

    public typealias RocketBaseView = NSView
#endif

typealias FailureHandler = ((Error?)->Void)

