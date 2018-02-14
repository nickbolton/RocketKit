//
//  ViewFactory.swift
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

class ViewFactory: NSObject {
    
    private let typeMap =
        [ComponentType.container : RocketView.self]

    // MARK: Public
    
    public func buildView(with component: RocketComponent) -> ComponentView {
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
