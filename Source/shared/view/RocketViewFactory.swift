//
//  RocketViewFactory.swift
//  RocketKit
//
//  Created by Nick Bolton on 5/6/17.
//  Copyright © 2017 Nick Bolton. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

class RocketViewFactory: NSObject {
    
    private let typeMap =
        [RocketComponentType.container : RocketView.self]

    // MARK: Public
    
    public func buildView(with component: RocketComponent) -> RocketViewProtocol {
        var viewType = typeMap[component.componentType]
        if viewType == nil {
            print("No type defined for component type: \(component.componentType)")
            viewType = typeMap[.container]
        }
        let view = viewType!.init()
        view.component = component
        return view
    }
}
