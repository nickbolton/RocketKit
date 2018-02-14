//
//  FontManagerProtocol.swift
//  RocketKit
//
//  Created by Nick Bolton on 12/31/17.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

public protocol FontManagerProtocol {
    
    static var shared: FontManagerProtocol { get }
    
    var availableFontNames: [String] { get }
    var defaultWeight: CGFloat { get }
    var systemFamilyName: String { get }
    
    func defaultFontForFamily(_ familyName: String, with size: CGFloat) -> FontType
    func fontMembersForFamily(_ familyName: String) -> [FontFamilyMember]
    func memberFont(_ member: FontFamilyMember, with size: CGFloat) -> FontType
    func applyMember(_ member: FontFamilyMember, to font: FontType) -> FontType
    func loadFonts()
}
