//
//  TextContentProvider.swift
//  RocketKit
//
//  Created by Nick Bolton on 1/1/18.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

typealias TextContentSuccessHandler = (([String])->Void)

protocol TextContentProvider {
    func textContent(for component: RocketComponent, onSuccess: TextContentSuccessHandler?, onFailure: FailureHandler?)
}
