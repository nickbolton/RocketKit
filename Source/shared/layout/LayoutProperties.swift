//
//  LayoutProperties.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/15/18.
//

import UIKit

public protocol StackLayoutProperties {
    var spacingBefore: CGFloat { get set }
    var spacingAfter: CGFloat { get set }
    var flexGrow: CGFloat { get set }
    var flexShrink: CGFloat { get set }
}

public protocol AbsoluteLayoutProperties {
    var position: CGPoint { get set }
}

public class LayoutProperties: NSObject, StackLayoutProperties, AbsoluteLayoutProperties, Exportable, Importable {

    private let lock = DispatchSemaphore(value: 1)

    private func blocking<T>(_ block: ()->T) -> T {
        lock.wait()
        defer { lock.signal() }
        return block()
    }

    private var _spacingBefore: CGFloat = 0.0
    public var spacingBefore: CGFloat {
        get { return blocking { return _spacingBefore } }
        set { blocking { _spacingBefore = newValue } }
    }
    private var _spacingAfter: CGFloat = 0.0
    public var spacingAfter: CGFloat {
        get { return blocking { return _spacingAfter } }
        set { blocking { _spacingAfter = newValue } }
    }
    private var _flexGrow: CGFloat = 0.0
    public var flexGrow: CGFloat {
        get { return blocking { return _flexGrow } }
        set { blocking { _flexGrow = newValue } }
    }
    private var _flexShrink: CGFloat = 0.0
    public var flexShrink: CGFloat {
        get { return blocking { return _flexShrink } }
        set { blocking { _flexShrink = newValue } }
    }
    private var _selfAlign = StackSelfAlignment.auto
    public var selfAlign: StackSelfAlignment {
        get { return blocking { return _selfAlign } }
        set { blocking { _selfAlign = newValue } }
    }

    private var _position: CGPoint = .zero
    public var position: CGPoint {
        get { return blocking { return _position } }
        set { blocking { _position = newValue } }
    }
    
    public var width: Dimension {
        get { return blocking { return size.width } }
        set { blocking { size.width = newValue } }
    }
    public var height: Dimension {
        get { return blocking { return size.height } }
        set { blocking { size.height = newValue } }
    }
    public var minWidth: Dimension {
        get { return blocking { return size.minWidth } }
        set { blocking { size.minWidth = newValue } }
    }
    public var minHeight: Dimension {
        get { return blocking { return size.minHeight } }
        set { blocking { size.minHeight = newValue } }
    }
    public var maxWidth: Dimension {
        get { return blocking { return size.maxWidth } }
        set { blocking { size.maxWidth = newValue } }
    }
    public var maxHeight: Dimension {
        get { return blocking { return size.maxHeight } }
        set { blocking { size.maxHeight = newValue } }
    }
    
    public var preferredSize: CGSize {
        get {
            return blocking {
                if size.width.unit == .fraction {
                    assert(false, "Cannot get preferredSize of element with fractional width. Width: \(size.width).")
                    return .zero
                }
                
                if size.height.unit == .fraction {
                    assert(false, "Cannot get preferredSize of element with fractional height. Height: \(size.height).")
                    return .zero
                }
                
                return CGSize(width: size.width.value, height: size.height.value)
            }
        }
        set {
            blocking {
                size.width = Dimension(value: newValue.width)
                size.height = Dimension(value: newValue.height)
            }
        }
    }
    
    public var minSize: CGSize {
        get { return blocking { return CGSize(width: size.minWidth.value, height: size.minHeight.value) } }
        set {
            blocking {
                size.minWidth = Dimension(value: newValue.width)
                size.minHeight = Dimension(value: newValue.height)
            }
        }
    }
    
    public var maxSize: CGSize {
        get { return blocking { return CGSize(width: size.maxWidth.value, height: size.maxHeight.value) } }
        set {
            blocking {
                size.maxWidth = Dimension(value: newValue.width)
                size.maxHeight = Dimension(value: newValue.height)
            }
        }
    }
    
    public var minLayoutSize: DimensionSize {
        get { return blocking { return DimensionSize(width: size.minWidth, height: size.minHeight) } }
        set {
            blocking {
                size.minWidth = newValue.width
                size.minHeight = newValue.height
            }
        }
    }
    
    public var maxLayoutSize: DimensionSize {
        get { return blocking { return DimensionSize(width: size.maxWidth, height: size.maxHeight) } }
        set {
            blocking {
                size.maxWidth = newValue.width
                size.maxHeight = newValue.height
            }
        }
    }
    
    private var _size: LayoutSize = LayoutSize.default
    var size: LayoutSize {
        get { return blocking { return _size } }
        set { blocking { _size = newValue } }
    }

    public var isFlexibleInBothDirections: Bool { return flexGrow > 0 && flexShrink > 0 }
    
    private let spacingBeforeKey = "spacingBefore"
    private let spacingAfterKey = "spacingAfter"
    private let flexGrowKey = "flexGrow"
    private let flexShrinkKey = "flexShrink"
    private let selfAlignKey = "selfAlign"
    private let positionKey = "position"
    private let widthKey = "width"
    private let heightKey = "height"
    private let minWidthKey = "minWidth"
    private let minHeightKey = "minHeight"
    private let maxWidthKey = "maxWidth"
    private let maxHeightKey = "maxHeight"
    
    public required init(dictionary: [String: Any]) {
        self._spacingBefore = dictionary[spacingBeforeKey] as? CGFloat ?? 0.0
        self._spacingAfter = dictionary[spacingAfterKey] as? CGFloat ?? 0.0
        self._flexGrow = dictionary[flexGrowKey] as? CGFloat ?? 0.0
        self._flexShrink = dictionary[flexShrinkKey] as? CGFloat ?? 0.0
        self._selfAlign = dictionary[selfAlignKey] as? StackSelfAlignment ?? .auto
        self._position = dictionary[positionKey] as? CGPoint ?? .zero
        
        var width = Dimension.auto
        var height = Dimension.auto
        var minWidth = Dimension.auto
        var minHeight = Dimension.auto
        var maxWidth = Dimension.auto
        var maxHeight = Dimension.auto

        if let dict = dictionary[widthKey] as? [String: Any] {
            width = Dimension(dictionary: dict)
        }
        if let dict = dictionary[heightKey] as? [String: Any] {
            height = Dimension(dictionary: dict)
        }
        if let dict = dictionary[minWidthKey] as? [String: Any] {
            minWidth = Dimension(dictionary: dict)
        }
        if let dict = dictionary[minHeightKey] as? [String: Any] {
            minHeight = Dimension(dictionary: dict)
        }
        if let dict = dictionary[maxWidthKey] as? [String: Any] {
            maxWidth = Dimension(dictionary: dict)
        }
        if let dict = dictionary[maxHeightKey] as? [String: Any] {
            maxHeight = Dimension(dictionary: dict)
        }
        self._size = LayoutSize(width: width, height: height, minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
    }
    
    public override init() {
        
    }
    
    public func dictionaryRepresentation() -> [String: Any] {
        return [
            spacingBeforeKey: _spacingBefore,
            spacingAfterKey: _spacingAfter,
            flexGrowKey: _flexGrow,
            flexShrinkKey: _flexShrink,
            selfAlignKey: _selfAlign,
            positionKey: _position,
            widthKey: width.dictionaryRepresentation(),
            heightKey: height.dictionaryRepresentation(),
            minWidthKey: minWidth.dictionaryRepresentation(),
            minHeightKey: minHeight.dictionaryRepresentation(),
            maxWidthKey: maxWidth.dictionaryRepresentation(),
            maxHeightKey: maxHeight.dictionaryRepresentation(),
        ]
    }
}
