//
//  LocalizedTextContentProvider.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

class LocalizedTextContentProvider: TextContentProvider {
    func textContent(for component: RocketComponent, onSuccess: TextContentSuccessHandler? = nil, onFailure: FailureHandler? = nil) {
        let result = component.textDescriptor?.textDescriptors.map { td in td.text.localized() } ?? []
        onSuccess?(result)
    }
}
