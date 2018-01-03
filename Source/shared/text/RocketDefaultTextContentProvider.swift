//
//  RocketDefaultTextContentProvider.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

class RocketDefaultTextContentProvider: RocketTextContentProvider {
    func textContent(for component: RocketComponent, onSuccess: TextContentSuccessHandler? = nil, onFailure: RocketFailureHandler? = nil) {
        onSuccess?(component.textDescriptor?.text)
    }
}
