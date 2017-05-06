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
    import AppKit
#endif

class ViewFactory: NSObject {
    
    private let typeMap =
        [ComponentType.container : RocketView.self]

    // MARK: Public
    
    public func buildView(with component: Component) -> RocketViewProtocol {
        guard let viewType = typeMap[component.componentType] else {
            assert(false, "No type defined for component type: \(component.componentType)")
        }
        let view = viewType.init()
        view.component = component
        return view
    }
}
