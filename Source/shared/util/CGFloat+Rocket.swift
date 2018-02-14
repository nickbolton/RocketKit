//
//  CGFloat+Rocket.swift
//  Pods-RocketTestObjc
//
//  Created by Nick Bolton on 2/13/18.
//

import Foundation

extension CGFloat {
    var halfPointCeilValue: CGFloat { return ceil(to: 2.0) }
    var halfPointRoundValue: CGFloat { return round(to: 2.0) }
        
    func round(to precision: CGFloat) -> CGFloat {
        if precision > 1.0 {
            return Darwin.round(self * precision) / precision;
        }
        return self;
    }
    
    func ceil(to precision: CGFloat) -> CGFloat {
        if precision > 1.0 {
            return Darwin.ceil(self * precision) / precision
        }
        return self
    }
}
