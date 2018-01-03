//
//  RocketFontManagerProtocol.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public protocol RocketFontManagerProtocol {
    
    static var shared: RocketFontManagerProtocol { get }
    
    var availableFontNames: [String] { get }
    var defaultWeight: CGFloat { get }
    var systemFamilyName: String { get }
    
    func defaultFontForFamily(_ familyName: String, with size: CGFloat) -> RocketFontType
    func fontMembersForFamily(_ familyName: String) -> [RocketFontFamilyMember]
    func memberFont(_ member: RocketFontFamilyMember, with size: CGFloat) -> RocketFontType
    func applyMember(_ member: RocketFontFamilyMember, to font: RocketFontType) -> RocketFontType
    func loadFonts()
}
