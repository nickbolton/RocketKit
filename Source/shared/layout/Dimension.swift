//
//  Dimension.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/16/18.
//

import UIKit

public enum DimensionUnit {
    case auto
    case points
    case fraction
}

public let dimensionUndefined: CGFloat = .nan
public let dimensionInfinity: CGFloat = CGFloat.greatestFiniteMagnitude

public struct Dimension: Exportable, Importable, Equatable {
    
    public let unit: DimensionUnit
    public let value: CGFloat
    
    public static let auto = Dimension(unit: .auto, value: 0.0)
    
    static private let unitKey = "unit"
    static private let valueKey = "value"
    
    init(dictionary: [String: Any]) {
        let unit = dictionary[Dimension.unitKey] as? DimensionUnit ?? .points
        let value = dictionary[Dimension.valueKey] as? CGFloat ?? 0.0
        self.init(unit: unit, value: value)
    }
    
    init(unit: DimensionUnit = .points, value: CGFloat) {
        self.unit = unit
        self.value = value
        switch unit {
        case .auto:
            assert(self.value == 0.0, "Dimension auto value must be 0.")
        case .points:
            assert(self.value >= 0 && self.value <= CGFloat.greatestFiniteMagnitude, "Dimension points Must be a real positive integer: \(self.value).")
        case .fraction:
            assert(0.0 <= self.value && self.value <= 1.0, "Dimension fraction value (\(self.value)) must be between 0 and 1.")
        }
    }
    
    /**
     * Returns a dimension by parsing the specified dimension string.
     * Examples: ASDimensionMake(@"50%") = ASDimensionMake(ASDimensionUnitFraction, 0.5)
     *           ASDimensionMake(@"0.5pt") = ASDimensionMake(ASDimensionUnitPoints, 0.5)
     */
    init(string dimension: String) {
        var unit = DimensionUnit.auto
        var value: CGFloat = 0.0
        if (dimension.count > 0) {

            let lowercased = dimension.lowercased()
            
            // Handle points
            if lowercased.hasSuffix("pt") {
                unit = .points
                value = CGFloat(NumberFormatter().number(from: dimension)?.floatValue ?? 0.0)
            } else if lowercased.hasSuffix("%") {
                unit = .fraction
                let formatter = NumberFormatter()
                formatter.numberStyle = .percent
                formatter.multiplier = 100.0
                value = CGFloat(formatter.number(from: dimension)?.floatValue ?? 0.0)
            }
        }
        
        self.init(unit: unit, value: value)
    }
    
    public var string: String {
        switch unit {
        case .points:
            return String(format: "%.0fpt", value)
        case .fraction:
            return String(format: "%.0f%%", value * 100.0)
        case .auto:
            return "auto"
        }
    }
    
    public func resolve(parentSize: CGFloat, autoSize: CGFloat) -> CGFloat {
        switch unit {
        case .auto:
            return autoSize
        case .points:
            return value
        case .fraction:
            return value * parentSize
        }
    }
    
    func dictionaryRepresentation() -> [String : Any] {
        return [Dimension.unitKey : unit, Dimension.valueKey : value]
    }
    
    static let `default` = Dimension(unit: .auto, value: 0.0)
    
    public static func ==(lhs: Dimension, rhs: Dimension) -> Bool {
        return lhs.unit == rhs.unit && lhs.value == rhs.value
    }

    static public func isPointsValidForLayout(_ points: CGFloat) -> Bool {
        return (points.isNormal || points == 0.0) && points >= 0.0 && points < (CGFloat.greatestFiniteMagnitude / 2.0)
    }
    
    static public func isSizeValidForLayout(_ size: CGSize) -> Bool {
        return isPointsValidForLayout(size.width) && isPointsValidForLayout(size.height)
    }
    
    static public func isPointsValidForSize(_ points: CGFloat) -> Bool {
        return (points.isNormal || points == 0.0) && points >= 0.0 && points < (CGFloat.greatestFiniteMagnitude / 2.0)
    }
    
    static public func isSizeValidForSize(_ size: CGSize) -> Bool {
        return isPointsValidForSize(size.width) && isPointsValidForSize(size.height)
    }
    
    static public func isPositionPointsValidForLayout(_ points: CGFloat) -> Bool {
        return (points.isNormal || points == 0.0) && points < (CGFloat.greatestFiniteMagnitude / 2.0)
    }
    
    static public func isPositionValidForLayout(_ point: CGPoint) -> Bool {
        return isPositionPointsValidForLayout(point.x) && isPositionPointsValidForLayout(point.y)
    }
    
    static public func isRectValidForLayout(_ rect: CGRect) -> Bool {
        return isPositionValidForLayout(rect.origin) && isSizeValidForLayout(rect.size)
    }
}

public struct DimensionSize: Exportable, Importable, Equatable {
    let width: Dimension
    let height: Dimension
    
    static let auto: DimensionSize = DimensionSize(width: .auto, height: .auto)
    
    private let widthKey = "width"
    private let heightKey = "height"
    
    public var string: String {
        return"{\(width.string), \(height.string)}"
    }
    
    init(dictionary: [String: Any]) {
        self.width = dictionary[widthKey] as? Dimension ?? Dimension.default
        self.height = dictionary[heightKey] as? Dimension ?? Dimension.default
    }
    
    init(width: Dimension, height: Dimension) {
        self.width = width
        self.height = height
    }
    
    public func resolve(parentSize: CGSize, autoSize: CGSize) -> CGSize {
        return CGSize(width: width.resolve(parentSize: parentSize.width, autoSize: autoSize.width),
                      height: height.resolve(parentSize: parentSize.height, autoSize: autoSize.height))
    }
    
    func dictionaryRepresentation() -> [String : Any] {
        return [widthKey : width.dictionaryRepresentation(), heightKey : height.dictionaryRepresentation()]
    }
    
    static let `default` = DimensionSize(width: .default, height: .default)
    
    public static func ==(lhs: DimensionSize, rhs: DimensionSize) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
}

struct LayoutSize: Equatable {
    var width: Dimension
    var height: Dimension
    var minWidth: Dimension
    var maxWidth: Dimension
    var minHeight: Dimension
    var maxHeight: Dimension
    
    static let `default` = LayoutSize()
    
    var string: String {
        return String(format: "<ASLayoutElementSize: exact={%@, %@}, min={%@, %@}, max={%@, %@}>",
                      width.string, height.string, minWidth.string, maxWidth.string, minHeight.string, maxHeight.string)
    }
    
    init(width: Dimension = .auto, height: Dimension = .auto, minWidth: Dimension = .auto, maxWidth: Dimension = .auto, minHeight: Dimension = .auto, maxHeight: Dimension = .auto) {
        self.width = width
        self.height = height
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    init(size: CGSize) {
        self.init(width: Dimension(value: size.width), height: Dimension(value: size.height), minWidth: Dimension.auto, maxWidth: Dimension.auto, minHeight: Dimension.auto, maxHeight: Dimension.auto)
    }
    
    func resolve(parentSize: CGSize) -> SizeRange {
        return resolveAutoSize(parentSize: parentSize, autoSizeRange: SizeRange.unconstrained)
    }
    
    func resolveAutoSize(parentSize: CGSize, autoSizeRange: SizeRange) -> SizeRange {
        let exact = DimensionSize(width: width, height: height).resolve(parentSize: parentSize, autoSize: CGSize(width: CGFloat.nan, height: CGFloat.nan))
        let min = DimensionSize(width: minWidth, height: minHeight).resolve(parentSize: parentSize, autoSize: autoSizeRange.min)
        let max = DimensionSize(width: maxWidth, height: maxHeight).resolve(parentSize: parentSize, autoSize: autoSizeRange.max)
        
        let (widthMin, widthMax) = constrain(min: min.width, exact: exact.width, max: max.width)
        let (heightMin, heightMax) = constrain(min: min.height, exact: exact.height, max: max.height)
        
        return SizeRange(min: CGSize(width: widthMin, height: heightMin), max: CGSize(width: widthMax, height: heightMax))
    }
    
    func constrain(min: CGFloat, exact: CGFloat, max: CGFloat) -> (CGFloat, CGFloat) {
        assert(!min.isNaN, "min must not be NaN")
        assert(!max.isNaN, "max must not be NaN")
        // Avoid use of min/max primitives since they're harder to reason
        // about in the presence of NaN (in exactVal)
        // Follow CSS: min overrides max overrides exact.
        
        // Begin with the min/max range
        var minResult = min
        var maxResult = max

        if max <= min {
            // min overrides max and exactVal is irrelevant
            maxResult = min
        } else if !exact.isNaN {
            if exact > max {
                // clip to max value
                minResult = max
            } else if exact < min {
                // clip to min value
                maxResult = min
            } else {
                // use exact value
                minResult = exact
                maxResult = exact
            }
        }
        
        return (minResult, maxResult)
    }
    
    static func ==(lhs: LayoutSize, rhs: LayoutSize) -> Bool {
        return lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.minWidth == rhs.minWidth
            && lhs.maxWidth == rhs.maxWidth
            && lhs.minHeight == rhs.minHeight
            && lhs.maxHeight == rhs.maxHeight
    }
}

struct Range: Equatable {
    var min: CGFloat = 0.0
    var max: CGFloat = 0.0
    
    func intersection(with other: Range) -> Range {
        let newMin = Swift.max(min, other.min)
        let newMax = Swift.min(max, other.max)
        if newMin <= newMax {
            return Range(min: newMin, max: newMax)
        } else {
            // No intersection. If we're before the other range, return our max; otherwise our min.
            if min < other.min {
                return Range(min: max, max: max)
            } else {
                return Range(min: min, max: min)
            }
        }
    }
    
    static func ==(lhs: Range, rhs: Range) -> Bool {
        return lhs.min == rhs.min && lhs.max == rhs.max
    }
}

public struct SizeRange: Equatable {
    var min = CGSize.zero
    var max = CGSize.zero
    
    public static let zero = SizeRange(min: .zero, max: .zero)
    public static let unconstrained = SizeRange(min: .zero, max: CGSize(width: dimensionInfinity, height: dimensionInfinity))
    
    init(size: CGSize) {
        self.min = size
        self.max = size
    }
    
    init(min: CGSize, max: CGSize) {
        self.min = min
        self.max = max
    }
    
    public func intersection(with range: SizeRange) -> SizeRange {
        let wRange = Range(min: min.width, max: max.width).intersection(with: Range(min: range.min.width, max: range.max.width))
        let hRange = Range(min: min.height, max: max.height).intersection(with: Range(min: range.min.height, max: range.max.height))
        return SizeRange(min: CGSize(width: wRange.min, height: hRange.min), max: CGSize(width: wRange.max, height: hRange.max))
    }

    public func clamp(to size: CGSize) -> CGSize {
        return CGSize(width: Swift.max(min.width, Swift.min(max.width, size.width)),
                      height: Swift.max(min.height, Swift.min(max.height, size.height)))
    }
    
    public static func ==(lhs: SizeRange, rhs: SizeRange) -> Bool {
        return lhs.min == rhs.min && lhs.max == rhs.max
    }
}

extension CGPoint {
    static public let null = CGPoint(x: CGFloat.nan, y: CGFloat.nan)    
    public var isNull: Bool { return x.isNaN && y.isNaN }
}
