//
//  StackLayoutSpec.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/16/18.
//

import UIKit

public enum StackAxis {
    case horizontal
    case vertical
}

/** If no children are flexible, how should this spec justify its children in the available space? */
public enum StackItemJustification {
    /**
     On overflow, children overflow out of this spec's bounds on the right/bottom side.
     On underflow, children are left/top-aligned within this spec's bounds.
     */
    case start
    /**
     On overflow, children are centered and overflow on both sides.
     On underflow, children are centered within this spec's bounds in the stacking direction.
     */
    case center
    /**
     On overflow, children overflow out of this spec's bounds on the left/top side.
     On underflow, children are right/bottom-aligned within this spec's bounds.
     */
    case end
    /**
     On overflow or if the stack has only 1 child, this value is identical to ASStackLayoutJustifyContentStart.
     Otherwise, the starting edge of the first child is at the starting edge of the stack,
     the ending edge of the last child is at the ending edge of the stack, and the remaining children
     are distributed so that the spacing between any two adjacent ones is the same.
     If there is a remaining space after spacing division, it is combined with the last spacing (i.e the one between the last 2 children).
     */
    case between
    /**
     On overflow or if the stack has only 1 child, this value is identical to ASStackLayoutJustifyContentCenter.
     Otherwise, children are distributed such that the spacing between any two adjacent ones is the same,
     and the spacing between the first/last child and the stack edges is half the size of the spacing between children.
     If there is a remaining space after spacing division, it is combined with the last spacing (i.e the one between the last child and the stack ending edge).
     */
    case around
}

/** Orientation of children along cross axis */
public enum StackAlignment {
    /** Align children to start of cross axis */
    case start
    /** Align children with end of cross axis */
    case end
    /** Center children on cross axis */
    case center
    /** Expand children to fill cross axis */
    case stretch
    case none
}

/**
 Each child may override their parent stack's cross axis alignment.
 @see ASStackLayoutAlignItems
 */
public enum StackSelfAlignment {
    /** Inherit alignment value from containing stack. */
    case auto
    /** Align to start of cross axis */
    case start
    /** Align with end of cross axis */
    case end
    /** Center on cross axis */
    case center
    /** Expand to fill cross axis */
    case stretch
    
    public func stackAlignment(_ stackAlignment: StackAlignment) -> StackAlignment {
        switch self {
        case .center:
            return .center
        case .end:
            return .end
        case .start:
            return .start
        case .stretch:
            return .stretch
        default:
            return stackAlignment;
        }
    }

}

/** Whether children are stacked into a single or multiple lines. */
public enum StackFlexWrap {
    case noWrap
    case wrap
}

/** Orientation of lines along cross axis if there are multiple lines. */
public enum StackContentAlignment {
    case start
    case center
    case end
    case spaceBetween
    case spaceAround
    case stretch
}

/** Orientation of children along horizontal axis */
public enum StackHorizontalAlignment {
    case none
    case left
    case middle
    case right
    
    public func stackAlignment(_ defaultAlignment: StackAlignment) -> StackAlignment {
        switch self {
        case .left:
            return .start
        case .middle:
            return .center
        case .right:
            return .end
        default:
            return defaultAlignment
        }
    }
    
    public func justifyContent(_ defaultJustifyContent: StackItemJustification) -> StackItemJustification {
        switch self {
        case .left:
            return .start
        case .middle:
            return .center
        case .right:
            return .end
        default:
            return defaultJustifyContent;
        }
    }
}

/** Orientation of children along vertical axis */
public enum StackVerticalAlignment {
    case none
    case top
    case center
    case bottom
    
    public func stackAlignment(_ defaultAlignment: StackAlignment) -> StackAlignment {
        switch self {
        case .top:
            return .start
        case .center:
            return .center
        case .bottom:
            return .end
        default:
            return defaultAlignment
        }
    }
    
    public func justifyContent(_ defaultJustifyContent: StackItemJustification) -> StackItemJustification {
        switch self {
        case .top:
            return .start
        case .center:
            return .center
        case .bottom:
            return .end
        default:
            return defaultJustifyContent;
        }
    }
}

public class StackLayoutSpec: NSObject, LayoutSpec {
    public let specType: LayoutSpecType = .stack
    
    /**
     Specifies the direction children are stacked in. If horizontalAlignment and verticalAlignment were set,
     they will be resolved again, causing justifyContent and alignItems to be updated accordingly
     */
    public var axis = StackAxis.horizontal
    
    /** The amount of space between each child. */
    public var spacing: CGFloat = 0.0
    
    /**
     Specifies how children are aligned horizontally. Depends on the stack direction, setting the alignment causes either
     justifyContent or alignItems to be updated. The alignment will remain valid after future direction changes.
     Thus, it is preferred to those properties
     */
    public var horizontalAlignment = StackHorizontalAlignment.none
    
    /**
     Specifies how children are aligned vertically. Depends on the stack direction, setting the alignment causes either
     justifyContent or alignItems to be updated. The alignment will remain valid after future direction changes.
     Thus, it is preferred to those properties
     */
    public var verticalAlignment = StackVerticalAlignment.none

    /** The amount of space between each child. Defaults to start */
    public var itemJustification = StackItemJustification.start

    /** Orientation of children along cross axis. Defaults to stretch */
    public var alignment = StackAlignment.stretch

    /** Whether children are stacked into a single or multiple lines. Defaults to single line (noWrap) */
    public var flexWrap = StackFlexWrap.noWrap
    
    /** Orientation of lines along cross axis if there are multiple lines. Defaults to start */
    public var contentAlignment = StackContentAlignment.start

    /** If the stack spreads on multiple lines using flexWrap, the amount of space between lines. */
    public var lineSpacing: CGFloat = 0.0
    
    private let axisKey = "axis"
    
    fileprivate let violationEpsilon: CGFloat = 0.01
    
    public required init(dictionary: [String: Any]) {
        self.axis = dictionary[axisKey] as? StackAxis ?? .horizontal
    }
    
    public override init() {
        
    }
    
    public func dictionaryRepresentation() -> [String : Any] {
        return [
            axisKey : axis
        ]
    }
    
    public func stackDimension(_ size: CGSize) -> CGFloat {
        return axis == .vertical ? size.height : size.width
    }
    
    public func crossDimension(_ size: CGSize) -> CGFloat {
        return axis == .vertical ? size.width : size.height
    }
    
    public func compareCrossDimension(_ a: CGSize, _ b: CGSize) -> Bool {
        return crossDimension(a) < crossDimension(b)
    }

    public func directionPoint(stack: CGFloat, cross: CGFloat) -> CGPoint {
        return axis == .vertical ? CGPoint(x: cross, y: stack) : CGPoint(x: stack, y: cross)
    }
    
    public func directionSize(stack: CGFloat, cross: CGFloat) -> CGSize {
        return axis == .vertical ? CGSize(width: cross, height: stack) : CGSize(width: stack, height: cross)
    }
    
    public func setStackValueToPoint(stack: CGFloat, point: inout CGPoint) {
        axis == .vertical ? (point.y = stack) : (point.x = stack)
    }
    
    public func directionSizeRange(stackMin: CGFloat, stackMax: CGFloat, crossMin: CGFloat, crossMax: CGFloat) -> SizeRange {
        return SizeRange(min: directionSize(stack: stackMin, cross: crossMin), max: directionSize(stack: stackMax, cross: crossMax))
    }
    
    public func layoutThatFits(_ component: RocketComponent, in constrainedSize: SizeRange) -> Layout {
        
        let unpositionedLayout = computeUnpositionedLayout(component, in: constrainedSize)
        computePositionedLayout(component, unpositioned: unpositionedLayout, in: constrainedSize)
        
//        as_activity_scope_verbose(as_activity_create("Calculate stack layout", AS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT));
//        as_log_verbose(ASLayoutLog(), "Stack layout %@", self);
        
        // Accessing the style and size property is pretty costly we create layout spec children we use to figure
        // out the layout for each child
//        const auto stackChildren = AS::map(children, [&](const id<ASLayoutElement> child) -> ASStackLayoutSpecChild {
//        ASLayoutElementStyle *style = child.style;
//        return {child, style, style.size};
//        });
        
//        const ASStackLayoutSpecStyle style = {.direction = _direction, .spacing = _spacing, .justifyContent = _justifyContent, .alignItems = _alignItems, .flexWrap = _flexWrap, .alignContent = _alignContent, .lineSpacing = _lineSpacing};
        
//        const auto unpositionedLayout = ASStackUnpositionedLayout::compute(stackChildren, style, constrainedSize, _concurrent);
//        const auto positionedLayout = ASStackPositionedLayout::compute(unpositionedLayout, style, constrainedSize);
//
//        if (style.direction == ASStackLayoutDirectionVertical) {
//            self.style.ascender = stackChildren.front().style.ascender;
//            self.style.descender = stackChildren.back().style.descender;
//        }
//
//        NSMutableArray *sublayouts = [NSMutableArray array];
//        for (const auto &item : positionedLayout.items) {
//            [sublayouts addObject:item.layout];
//        }
//
//        return [ASLayout layoutWithLayoutElement:self size:positionedLayout.size sublayouts:sublayouts];
        return Layout(componentId: component.identifier)
    }
    
    private func computePositionedLayout(_ component: RocketComponent, unpositioned: [RocketComponent], in constrainedSize: SizeRange) {
        
    }
}

// unpositioned
extension StackLayoutSpec {
    
    fileprivate func computeUnpositionedLayout(_ component: RocketComponent, in constrainedSize: SizeRange, isConcurrent: Bool = true) -> [RocketComponent] {
        var result = [RocketComponent]()
        
//        guard component.childComponents.count > 0 else { return [] }
//
//        // If we have a fixed size in either dimension, pass it to children so they can resolve percentages against it.
//        // Otherwise, we pass ASLayoutElementParentDimensionUndefined since it will depend on the content.
//        let parentSize = CGSize(width: constrainedSize.min.width == constrainedSize.max.width ? constrainedSize.min.width : dimensionUndefined,
//                                height: constrainedSize.min.height == constrainedSize.max.height ? constrainedSize.min.height : dimensionUndefined)
//
//        // We may be able to avoid some redundant layout passes
//        let optimizedFlexing = useOptimizedFlexing(component, sizeRange: constrainedSize)
//
//        // We do a first pass of all the children, generating an unpositioned layout for each with an unbounded range along
//        // the stack dimension.  This allows us to compute the "intrinsic" size of each child and find the available violation
//        // which determines whether we must grow or shrink the flexible children.
//        layoutItemsAlongUnconstrainedStackDimension(component.childComponents,
//                                                    isConcurrent: isConcurrent,
//                                                    sizeRange: constrainedSize,
//                                                    parentSize: parentSize,
//                                                    optimizedFlexing: optimizedFlexing)
//
//        // Collect items into lines (https://www.w3.org/TR/css-flexbox-1/#algo-line-break)
//        std::vector<ASStackUnpositionedLine> lines = collectChildrenIntoLines(items, style, sizeRange);
//
//        // Resolve the flexible lengths (https://www.w3.org/TR/css-flexbox-1/#resolve-flexible-lengths)
//        flexLinesAlongStackDimension(lines, style, concurrent, sizeRange, parentSize, optimizedFlexing);
//
//        // Calculate the cross size of each flex line (https://www.w3.org/TR/css-flexbox-1/#algo-cross-line)
//        computeLinesCrossSizeAndBaseline(lines, style, sizeRange);
//
//        // Handle 'align-content: stretch' (https://www.w3.org/TR/css-flexbox-1/#algo-line-stretch)
//        // Determine the used cross size of each item (https://www.w3.org/TR/css-flexbox-1/#algo-stretch)
//        stretchLinesAlongCrossDimension(lines, style, concurrent, sizeRange, parentSize);
//
//        // Compute stack dimension sum of each line and the whole stack
//        CGFloat layoutStackDimensionSum = 0;
//        for (auto &line : lines) {
//            line.stackDimensionSum = computeItemsStackDimensionSum(line.items, style);
//            // layoutStackDimensionSum is the max stackDimensionSum among all lines
//            layoutStackDimensionSum = MAX(line.stackDimensionSum, layoutStackDimensionSum);
//        }
//        // Compute cross dimension sum of the stack.
//        // This should be done before `lines` are moved to a new ASStackUnpositionedLayout struct (i.e `std::move(lines)`)
//        CGFloat layoutCrossDimensionSum = computeLinesCrossDimensionSum(lines, style);
//
//        return {.lines = std::move(lines), .stackDimensionSum = layoutStackDimensionSum, .crossDimensionSum = layoutCrossDimensionSum};
//
        return result
    }
    
//    static CGFloat resolveCrossDimensionMaxForStretchChild(const ASStackLayoutSpecStyle &style,
//    const ASStackLayoutSpecChild &child,
//    const CGFloat stackMax,
//    const CGFloat crossMax)
//    {
//    // stretched children may have a cross direction max that is smaller than the minimum size constraint of the parent.
//    const CGFloat computedMax = (style.direction == ASStackLayoutDirectionVertical ?
//    ASLayoutElementSizeResolve(child.style.size, ASLayoutElementParentSizeUndefined).max.width :
//    ASLayoutElementSizeResolve(child.style.size, ASLayoutElementParentSizeUndefined).max.height);
//    return computedMax == INFINITY ? crossMax : computedMax;
//    }
    
//    private func resolveCrossDimensionMinForStretchChild(_ child: RocketComponent, stackMax: CGFloat, crossMin: CGFloat) -> CGFloat {
//        // stretched children will have a cross dimension of at least crossMin, unless they explicitly define a child size
//        // that is smaller than the constraint of the parent.
//        return axis == .vertical ?
//            child.layoutProperties
//            ASLayoutElementSizeResolve(child.style.size, ASLayoutElementParentSizeUndefined).min.width :
//            ASLayoutElementSizeResolve(child.style.size, ASLayoutElementParentSizeUndefined).min.height) ?: crossMin;
//    }
    
    /**
     Sizes the child given the parameters specified, and returns the computed layout.
     */
//    private func crossChildLayout(_ child: RocketComponent, stackMin: CGFloat, stackMax: CGFloat, crossMin: CGFloat, crossMax: CGFloat, parentSize: CGSize) -> Layout {
//        let alignment = child.layoutProperties.selfAlign.stackAlignment(self.alignment)
//        // stretched children will have a cross dimension of at least crossMin
//        let childCrossMin = alignment == .stretch ? resolveCrossDimensionMinForStretchChild(child, stackMax, crossMin) : 0
//        const CGFloat childCrossMax = (alignItems == ASStackLayoutAlignItemsStretch ?
//            resolveCrossDimensionMaxForStretchChild(style, child, stackMax, crossMax) :
//            crossMax);
//        const ASSizeRange childSizeRange = directionSizeRange(style.direction, stackMin, stackMax, childCrossMin, childCrossMax);
//        ASLayout *layout = [child.element layoutThatFits:childSizeRange parentSize:parentSize];
//        ASDisplayNodeCAssertNotNil(layout, @"ASLayout returned from -layoutThatFits:parentSize: must not be nil: %@", child.element);
//        return layout ? : [ASLayout layoutWithLayoutElement:child.element size:{0, 0}];
//    }
    
//    static void dispatchApplyIfNeeded(size_t iterationCount, BOOL forced, void(^work)(size_t i))
//{
//    if (iterationCount == 0) {
//    return;
//    }
//    
//    if (iterationCount == 1) {
//    work(0);
//    return;
//    }
//    
//    // TODO Once the locking situation in ASDisplayNode has improved, always dispatch if on main
//    if (forced == NO) {
//    for (size_t i = 0; i < iterationCount; i++) {
//    work(i);
//    }
//    return;
//    }
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    ASDispatchApply(iterationCount, queue, 0, work);
//    }
//    
//    /**
//     Computes the consumed cross dimension length for the given vector of lines and stacking style.
//     
//     Cross Dimension
//     +--------------------->
//     +--------+ +--------+ +--------+ +---------+
//     Vertical |Vertical| |Vertical| |Vertical| |Vertical |
//     Stack    | Line 1 | | Line 2 | | Line 3 | | Line 4  |
//     |        | |        | |        | |         |
//     +--------+ +--------+ +--------+ +---------+
//     crossDimensionSum
//     |------------------------------------------|
//     
//     @param lines unpositioned lines
//     */
//    static CGFloat computeLinesCrossDimensionSum(const std::vector<ASStackUnpositionedLine> &lines,
//    const ASStackLayoutSpecStyle &style)
//    {
//    return std::accumulate(lines.begin(), lines.end(),
//    // Start from default spacing between each line:
//    lines.empty() ? 0 : style.lineSpacing * (lines.size() - 1),
//    [&](CGFloat x, const ASStackUnpositionedLine &l) {
//    return x + l.crossSize;
//    });
//    }
//    
//    
//    /**
//     Computes the violation by comparing a cross dimension sum with the overall allowable size range for the stack.
//     
//     Violation is the distance you would have to add to the unbounded cross-direction length of the stack spec's
//     lines in order to bring the stack within its allowed sizeRange.  The diagram below shows 3 vertical stacks, each contains 3-5 vertical lines,
//     with the different types of violation.
//     
//     Cross Dimension
//     +--------------------->
//     cross size range
//     |------------|
//     +--------+ +--------+ +--------+ +---------+  -  -  -  -  -  -  -  -
//     Vertical |Vertical| |Vertical| |Vertical| |Vertical |     |                 ^
//     Stack 1  | Line 1 | | Line 2 | | Line 3 | | Line 4  | (zero violation)      | stack size range
//     |        | |        | |        | |  |      |     |                 v
//     +--------+ +--------+ +--------+ +---------+  -  -  -  -  -  -  -  -
//     |            |
//     +--------+ +--------+ +--------+  -  -  -  -  -  -  -  -  -  -  -  -
//     Vertical |        | |        | |        |    |            |                 ^
//     Stack 2  |        | |        | |        |<--> (positive violation)          | stack size range
//     |        | |        | |        |    |            |                 v
//     +--------+ +--------+ +--------+  -  -  -  -  -  -  -  -  -  -  -  -
//     |            |<------> (negative violation)
//     +--------+ +--------+ +--------+ +---------+ +-----------+  -  -   -
//     Vertical |        | |        | |        | |  |      | |   |       |         ^
//     Stack 3  |        | |        | |        | |         | |           |         |  stack size range
//     |        | |        | |        | |  |      | |   |       |         v
//     +--------+ +--------+ +--------+ +---------+ +-----------+  -  -   -
//     
//     @param crossDimensionSum the consumed length of the lines in the stack along the cross dimension
//     @param style layout style to be applied to all children
//     @param sizeRange the range of allowable sizes for the stack layout spec
//     */
//    CGFloat ASStackUnpositionedLayout::computeCrossViolation(const CGFloat crossDimensionSum,
//    const ASStackLayoutSpecStyle &style,
//    const ASSizeRange &sizeRange)
//    {
//    const CGFloat minCrossDimension = crossDimension(style.direction, sizeRange.min);
//    const CGFloat maxCrossDimension = crossDimension(style.direction, sizeRange.max);
//    if (crossDimensionSum < minCrossDimension) {
//    return minCrossDimension - crossDimensionSum;
//    } else if (crossDimensionSum > maxCrossDimension) {
//    return maxCrossDimension - crossDimensionSum;
//    }
//    return 0;
//    }
//    
//    /**
//     Stretches children to lay out along the cross axis according to the alignment stretch settings of the children
//     (child.alignSelf), and the stack layout's alignment settings (style.alignItems).  This does not do the actual alignment
//     of the items once stretched though; ASStackPositionedLayout will do centering etc.
//     
//     Finds the maximum cross dimension among child layouts.  If that dimension exceeds the minimum cross layout size then
//     we must stretch any children whose alignItems specify ASStackLayoutAlignItemsStretch.
//     
//     The diagram below shows 3 children in a horizontal stack.  The second child is larger than the minCrossDimension, so
//     its height is used as the childCrossMax.  Any children that are stretchable (which may be all children if
//     style.alignItems specifies stretch) like the first child must be stretched to match that maximum.  All children must be
//     at least minCrossDimension in cross dimension size, which is shown by the sizing of the third child.
//     
//     Stack Dimension
//     +--------------------->
//     +  +-+-------------+-+-------------+--+---------------+  + + +
//     |    | child.      | |             |  |               |  | | |
//     |    | alignSelf   | |             |  |               |  | | |
//     Cross        |    | = stretch   | |             |  +-------+-------+  | | |
//     Dimension    |    +-----+-------+ |             |  |       |       |  | | |
//     |    |     |       | |             |          |          | | |
//     |          |         |             |  |       v       |  | | |
//     v  +-+- - - - - - -+-+ - - - - - - +--+- - - - - - - -+  | | + minCrossDimension
//     |         |             |                     | |
//     |     v       | |             |                     | |
//     +- - - - - - -+ +-------------+                     | + childCrossMax
//     |
//     +--------------------------------------------------+  + crossMax
//     
//     @param items pre-computed items; modified in-place as needed
//     @param style the layout style of the overall stack layout
//     */
//    static void stretchItemsAlongCrossDimension(std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style,
//    const BOOL concurrent,
//    const CGSize parentSize,
//    const CGFloat crossSize)
//    {
//    dispatchApplyIfNeeded(items.size(), concurrent, ^(size_t i) {
//    auto &item = items[i];
//    const ASStackLayoutAlignItems alignItems = alignment(item.child.style.alignSelf, style.alignItems);
//    if (alignItems == ASStackLayoutAlignItemsStretch) {
//    const CGFloat cross = crossDimension(style.direction, item.layout.size);
//    const CGFloat stack = stackDimension(style.direction, item.layout.size);
//    const CGFloat violation = crossSize - cross;
//    
//    // Only stretch if violation is positive. Compare against kViolationEpsilon here to avoid stretching against a tiny violation.
//    if (violation > kViolationEpsilon) {
//    item.layout = crossChildLayout(item.child, style, stack, stack, crossSize, crossSize, parentSize);
//    }
//    }
//    });
//    }
//    
//    /**
//     * Stretch lines and their items according to alignContent, alignItems and alignSelf.
//     * https://www.w3.org/TR/css-flexbox-1/#algo-line-stretch
//     * https://www.w3.org/TR/css-flexbox-1/#algo-stretch
//     */
//    static void stretchLinesAlongCrossDimension(std::vector<ASStackUnpositionedLine> &lines,
//    const ASStackLayoutSpecStyle &style,
//    const BOOL concurrent,
//    const ASSizeRange &sizeRange,
//    const CGSize parentSize)
//    {
//    ASDisplayNodeCAssertFalse(lines.empty());
//    const std::size_t numOfLines = lines.size();
//    const CGFloat violation = ASStackUnpositionedLayout::computeCrossViolation(computeLinesCrossDimensionSum(lines, style), style, sizeRange);
//    // Don't stretch if the stack is single line, because the line's cross size was clamped against the stack's constrained size.
//    const BOOL shouldStretchLines = (numOfLines > 1
//    && style.alignContent == ASStackLayoutAlignContentStretch
//    && violation > kViolationEpsilon);
//    
//    CGFloat extraCrossSizePerLine = violation / numOfLines;
//    for (auto &line : lines) {
//    if (shouldStretchLines) {
//    line.crossSize += extraCrossSizePerLine;
//    }
//    
//    stretchItemsAlongCrossDimension(line.items, style, concurrent, parentSize, line.crossSize);
//    }
//    }
//    
//    static BOOL itemIsBaselineAligned(const ASStackLayoutSpecStyle &style,
//    const ASStackLayoutSpecItem &l)
//    {
//    ASStackLayoutAlignItems alignItems = alignment(l.child.style.alignSelf, style.alignItems);
//    return alignItems == ASStackLayoutAlignItemsBaselineFirst || alignItems == ASStackLayoutAlignItemsBaselineLast;
//    }
//    
//    CGFloat ASStackUnpositionedLayout::baselineForItem(const ASStackLayoutSpecStyle &style,
//    const ASStackLayoutSpecItem &item)
//    {
//    switch (alignment(item.child.style.alignSelf, style.alignItems)) {
//    case ASStackLayoutAlignItemsBaselineFirst:
//    return item.child.style.ascender;
//    case ASStackLayoutAlignItemsBaselineLast:
//    return crossDimension(style.direction, item.layout.size) + item.child.style.descender;
//    default:
//    return 0;
//    }
//    }
//    
//    /**
//     * Computes cross size and baseline of each line.
//     * https://www.w3.org/TR/css-flexbox-1/#algo-cross-line
//     *
//     * @param lines All items to lay out
//     * @param style the layout style of the overall stack layout
//     * @param sizeRange the range of allowable sizes for the stack layout component
//     */
//    static void computeLinesCrossSizeAndBaseline(std::vector<ASStackUnpositionedLine> &lines,
//    const ASStackLayoutSpecStyle &style,
//    const ASSizeRange &sizeRange)
//    {
//    ASDisplayNodeCAssertFalse(lines.empty());
//    const BOOL isSingleLine = (lines.size() == 1);
//    
//    const auto minCrossSize = crossDimension(style.direction, sizeRange.min);
//    const auto maxCrossSize = crossDimension(style.direction, sizeRange.max);
//    const BOOL definiteCrossSize = (minCrossSize == maxCrossSize);
//    
//    // If the stack is single-line and has a definite cross size, the cross size of the line is the stack's definite cross size.
//    if (isSingleLine && definiteCrossSize) {
//    auto &line = lines[0];
//    line.crossSize = minCrossSize;
//    
//    // We still need to determine the line's baseline
//    //TODO unit test
//    for (const auto &item : line.items) {
//    if (itemIsBaselineAligned(style, item)) {
//    CGFloat baseline = ASStackUnpositionedLayout::baselineForItem(style, item);
//    line.baseline = MAX(line.baseline, baseline);
//    }
//    }
//    
//    return;
//    }
//    
//    for (auto &line : lines) {
//    const auto &items = line.items;
//    CGFloat maxStartToBaselineDistance = 0;
//    CGFloat maxBaselineToEndDistance = 0;
//    CGFloat maxItemCrossSize = 0;
//    
//    for (const auto &item : items) {
//    if (itemIsBaselineAligned(style, item)) {
//    // Step 1. Collect all the items whose align-self is baseline. Find the largest of the distances
//    // between each item’s baseline and its hypothetical outer cross-start edge (aka. its baseline value),
//    // and the largest of the distances between each item’s baseline and its hypothetical outer cross-end edge,
//    // and sum these two values.
//    CGFloat baseline = ASStackUnpositionedLayout::baselineForItem(style, item);
//    maxStartToBaselineDistance = MAX(maxStartToBaselineDistance, baseline);
//    maxBaselineToEndDistance = MAX(maxBaselineToEndDistance, crossDimension(style.direction, item.layout.size) - baseline);
//    } else {
//    // Step 2. Among all the items not collected by the previous step, find the largest outer hypothetical cross size.
//    maxItemCrossSize = MAX(maxItemCrossSize, crossDimension(style.direction, item.layout.size));
//    }
//    }
//    
//    // Step 3. The used cross-size of the flex line is the largest of the numbers found in the previous two steps and zero.
//    line.crossSize = MAX(maxStartToBaselineDistance + maxBaselineToEndDistance, maxItemCrossSize);
//    if (isSingleLine) {
//    // If the stack is single-line, then clamp the line’s cross-size to be within the stack's min and max cross-size properties.
//    line.crossSize = MIN(MAX(minCrossSize, line.crossSize), maxCrossSize);
//    }
//    
//    line.baseline = maxStartToBaselineDistance;
//    }
//    }
//    
//    /**
//     Returns a lambda that computes the relevant flex factor based on the given violation.
//     @param violation The amount that the stack layout violates its size range.  See header for sign interpretation.
//     */
//    static std::function<CGFloat(const ASStackLayoutSpecItem &)> flexFactorInViolationDirection(const CGFloat violation)
//{
//    if (std::fabs(violation) < kViolationEpsilon) {
//    return [](const ASStackLayoutSpecItem &item) { return 0.0; };
//    } else if (violation > 0) {
//    return [](const ASStackLayoutSpecItem &item) { return item.child.style.flexGrow; };
//    } else {
//    return [](const ASStackLayoutSpecItem &item) { return item.child.style.flexShrink; };
//    }
//    }
//    
//    static inline CGFloat scaledFlexShrinkFactor(const ASStackLayoutSpecItem &item,
//    const ASStackLayoutSpecStyle &style,
//    const CGFloat flexFactorSum)
//    {
//    return stackDimension(style.direction, item.layout.size) * (item.child.style.flexShrink / flexFactorSum);
//    }
//    
//    /**
//     Returns a lambda that computes a flex shrink adjustment for a given item based on the provided violation.
//     @param items The unpositioned items from the original unconstrained layout pass.
//     @param style The layout style to be applied to all children.
//     @param violation The amount that the stack layout violates its size range.
//     @param flexFactorSum The sum of each item's flex factor as determined by the provided violation.
//     @return A lambda capable of computing the flex shrink adjustment, if any, for a particular item.
//     */
//    static std::function<CGFloat(const ASStackLayoutSpecItem &)> flexShrinkAdjustment(const std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style,
//    const CGFloat violation,
//    const CGFloat flexFactorSum)
//    {
//    const CGFloat scaledFlexShrinkFactorSum = std::accumulate(items.begin(), items.end(), 0.0, [&](CGFloat x, const ASStackLayoutSpecItem &item) {
//    return x + scaledFlexShrinkFactor(item, style, flexFactorSum);
//    });
//    return [style, scaledFlexShrinkFactorSum, violation, flexFactorSum](const ASStackLayoutSpecItem &item) {
//    if (scaledFlexShrinkFactorSum == 0.0) {
//    return (CGFloat)0.0;
//    }
//    
//    const CGFloat scaledFlexShrinkFactorRatio = scaledFlexShrinkFactor(item, style, flexFactorSum) / scaledFlexShrinkFactorSum;
//    // The item should shrink proportionally to the scaled flex shrink factor ratio computed above.
//    // Unlike the flex grow adjustment the flex shrink adjustment needs to take the size of each item into account.
//    return -std::fabs(scaledFlexShrinkFactorRatio * violation);
//    };
//    }
//    
//    /**
//     Returns a lambda that computes a flex grow adjustment for a given item based on the provided violation.
//     @param items The unpositioned items from the original unconstrained layout pass.
//     @param violation The amount that the stack layout violates its size range.
//     @param flexFactorSum The sum of each item's flex factor as determined by the provided violation.
//     @return A lambda capable of computing the flex grow adjustment, if any, for a particular item.
//     */
//    static std::function<CGFloat(const ASStackLayoutSpecItem &)> flexGrowAdjustment(const std::vector<ASStackLayoutSpecItem> &items,
//    const CGFloat violation,
//    const CGFloat flexFactorSum)
//    {
//    // To compute the flex grow adjustment distribute the violation proportionally based on each item's flex grow factor.
//    return [violation, flexFactorSum](const ASStackLayoutSpecItem &item) {
//    return std::floor(violation * (item.child.style.flexGrow / flexFactorSum));
//    };
//    }
//    
//    /**
//     Returns a lambda that computes a flex adjustment for a given item based on the provided violation.
//     @param items The unpositioned items from the original unconstrained layout pass.
//     @param style The layout style to be applied to all children.
//     @param violation The amount that the stack layout violates its size range.
//     @param flexFactorSum The sum of each item's flex factor as determined by the provided violation.
//     @return A lambda capable of computing the flex adjustment for a particular item.
//     */
//    static std::function<CGFloat(const ASStackLayoutSpecItem &)> flexAdjustmentInViolationDirection(const std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style,
//    const CGFloat violation,
//    const CGFloat flexFactorSum)
//    {
//    if (violation > 0) {
//    return flexGrowAdjustment(items, violation, flexFactorSum);
//    } else {
//    return flexShrinkAdjustment(items, style, violation, flexFactorSum);
//    }
//    }
//    
//    ASDISPLAYNODE_INLINE BOOL isFlexibleInBothDirections(const ASStackLayoutSpecChild &child)
//    {
//    return child.style.flexGrow > 0 && child.style.flexShrink > 0;
//    }
//    
//    /**
//     The flexible children may have been left not laid out in the initial layout pass, so we may have to go through and size
//     these children at zero size so that the children layouts are at least present.
//     */
//    static void layoutFlexibleChildrenAtZeroSize(std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style,
//    const BOOL concurrent,
//    const ASSizeRange &sizeRange,
//    const CGSize parentSize)
//    {
//    dispatchApplyIfNeeded(items.size(), concurrent, ^(size_t i) {
//    auto &item = items[i];
//    if (isFlexibleInBothDirections(item.child)) {
//    item.layout = crossChildLayout(item.child,
//    style,
//    0,
//    0,
//    crossDimension(style.direction, sizeRange.min),
//    crossDimension(style.direction, sizeRange.max),
//    parentSize);
//    }
//    });
//    }
//    
//    /**
//     Computes the consumed stack dimension length for the given vector of items and stacking style.
//     
//     stackDimensionSum
//     <----------------------->
//     +-----+  +-------+  +---+
//     |     |  |       |  |   |
//     |     |  |       |  |   |
//     +-----+  |       |  +---+
//     +-------+
//     
//     @param items unpositioned layouts for items
//     @param style the layout style of the overall stack layout
//     */
//    static CGFloat computeItemsStackDimensionSum(const std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style)
//    {
//    // Sum up the childrens' spacing
//    const CGFloat childSpacingSum = std::accumulate(items.begin(), items.end(),
//    // Start from default spacing between each child:
//    items.empty() ? 0 : style.spacing * (items.size() - 1),
//    [&](CGFloat x, const ASStackLayoutSpecItem &l) {
//    return x + l.child.style.spacingBefore + l.child.style.spacingAfter;
//    });
//    
//    // Sum up the childrens' dimensions (including spacing) in the stack direction.
//    const CGFloat childStackDimensionSum = std::accumulate(items.begin(), items.end(),
//    childSpacingSum,
//    [&](CGFloat x, const ASStackLayoutSpecItem &l) {
//    return x + stackDimension(style.direction, l.layout.size);
//    });
//    return childStackDimensionSum;
//    }
//    
//    //TODO move this up near computeCrossViolation and make both methods share the same code path, to make sure they share the same concept of "negative" and "positive" violations.
//    /**
//     Computes the violation by comparing a stack dimension sum with the overall allowable size range for the stack.
//     
//     Violation is the distance you would have to add to the unbounded stack-direction length of the stack spec's
//     children in order to bring the stack within its allowed sizeRange.  The diagram below shows 3 horizontal stacks with
//     the different types of violation.
//     
//     sizeRange
//     |------------|
//     +------+ +-------+ +-------+ +---------+
//     |      | |       | |       | |  |      |     |
//     |      | |       | |       | |         | (zero violation)
//     |      | |       | |       | |  |      |     |
//     +------+ +-------+ +-------+ +---------+
//     |            |
//     +------+ +-------+ +-------+
//     |      | |       | |       |    |            |
//     |      | |       | |       |<--> (positive violation)
//     |      | |       | |       |    |            |
//     +------+ +-------+ +-------+
//     |            |<------> (negative violation)
//     +------+ +-------+ +-------+ +---------+ +-----------+
//     |      | |       | |       | |  |      | |   |       |
//     |      | |       | |       | |         | |           |
//     |      | |       | |       | |  |      | |   |       |
//     +------+ +-------+ +-------+ +---------+ +-----------+
//     
//     @param stackDimensionSum the consumed length of the children in the stack along the stack dimension
//     @param style layout style to be applied to all children
//     @param sizeRange the range of allowable sizes for the stack layout spec
//     */
//    CGFloat ASStackUnpositionedLayout::computeStackViolation(const CGFloat stackDimensionSum,
//    const ASStackLayoutSpecStyle &style,
//    const ASSizeRange &sizeRange)
//    {
//    const CGFloat minStackDimension = stackDimension(style.direction, sizeRange.min);
//    const CGFloat maxStackDimension = stackDimension(style.direction, sizeRange.max);
//    if (stackDimensionSum < minStackDimension) {
//    return minStackDimension - stackDimensionSum;
//    } else if (stackDimensionSum > maxStackDimension) {
//    return maxStackDimension - stackDimensionSum;
//    }
//    return 0;
//    }
//    
    /**
     If we have a single flexible (both shrinkable and growable) child, and our allowed size range is set to a specific
     number then we may avoid the first "intrinsic" size calculation.
     */
    private func useOptimizedFlexing(_ component: RocketComponent, sizeRange: SizeRange) -> Bool {
        
        let flexibleChildren = component.childComponents.reduce(0) { $0 + ($1.layoutProperties.isFlexibleInBothDirections ? 1 : 0) }
        
        return ((flexibleChildren == 1) &&
                (stackDimension(sizeRange.min) == stackDimension(sizeRange.max)))
    }
    
//    /**
//     Flexes children in the stack axis to resolve a min or max stack size violation. First, determines which children are
//     flexible (see computeStackViolation and isFlexibleInViolationDirection). Then computes how much to flex each flexible child
//     and performs re-layout. Note that there may still be a non-zero violation even after flexing.
//     
//     The actual CSS flexbox spec describes an iterative looping algorithm here, which may be adopted in t5837937:
//     http://www.w3.org/TR/css3-flexbox/#resolve-flexible-lengths
//     
//     @param lines reference to unpositioned lines and items from the original, unconstrained layout pass; modified in-place
//     @param style layout style to be applied to all children
//     @param sizeRange the range of allowable sizes for the stack layout component
//     @param parentSize Size of the stack layout component. May be undefined in either or both directions.
//     */
//    static void flexLinesAlongStackDimension(std::vector<ASStackUnpositionedLine> &lines,
//    const ASStackLayoutSpecStyle &style,
//    const BOOL concurrent,
//    const ASSizeRange &sizeRange,
//    const CGSize parentSize,
//    const BOOL useOptimizedFlexing)
//    {
//    for (auto &line : lines) {
//    auto &items = line.items;
//    const CGFloat violation = ASStackUnpositionedLayout::computeStackViolation(computeItemsStackDimensionSum(items, style), style, sizeRange);
//    std::function<CGFloat(const ASStackLayoutSpecItem &)> flexFactor = flexFactorInViolationDirection(violation);
//    // The flex factor sum is needed to determine if flexing is necessary.
//    // This value is also needed if the violation is positive and flexible items need to grow, so keep it around.
//    const CGFloat flexFactorSum = std::accumulate(items.begin(), items.end(), 0.0, [&](CGFloat x, const ASStackLayoutSpecItem &item) {
//    return x + flexFactor(item);
//    });
//    
//    // If no items are able to flex then there is nothing left to do with this line. Bail.
//    if (flexFactorSum == 0) {
//    // If optimized flexing was used then we have to clean up the unsized items and lay them out at zero size.
//    if (useOptimizedFlexing) {
//    layoutFlexibleChildrenAtZeroSize(items, style, concurrent, sizeRange, parentSize);
//    }
//    continue;
//    }
//    
//    std::function<CGFloat(const ASStackLayoutSpecItem &)> flexAdjustment = flexAdjustmentInViolationDirection(items,
//    style,
//    violation,
//    flexFactorSum);
//    // Compute any remaining violation to the first flexible item.
//    const CGFloat remainingViolation = std::accumulate(items.begin(), items.end(), violation, [&](CGFloat x, const ASStackLayoutSpecItem &item) {
//    return x - flexAdjustment(item);
//    });
//    
//    size_t firstFlexItem = -1;
//    for(size_t i = 0; i < items.size(); i++) {
//    // Items are consider inflexible if they do not need to make a flex adjustment.
//    if (flexAdjustment(items[i]) != 0) {
//    firstFlexItem = i;
//    break;
//    }
//    }
//    if (firstFlexItem == -1) {
//    continue;
//    }
//    
//    dispatchApplyIfNeeded(items.size(), concurrent, ^(size_t i) {
//    auto &item = items[i];
//    const CGFloat currentFlexAdjustment = flexAdjustment(item);
//    // Items are consider inflexible if they do not need to make a flex adjustment.
//    if (currentFlexAdjustment != 0) {
//    const CGFloat originalStackSize = stackDimension(style.direction, item.layout.size);
//    // Only apply the remaining violation for the first flexible item that has a flex grow factor.
//    const CGFloat flexedStackSize = originalStackSize + currentFlexAdjustment + (i == firstFlexItem && item.child.style.flexGrow > 0 ? remainingViolation : 0);
//    item.layout = crossChildLayout(item.child,
//    style,
//    MAX(flexedStackSize, 0),
//    MAX(flexedStackSize, 0),
//    crossDimension(style.direction, sizeRange.min),
//    crossDimension(style.direction, sizeRange.max),
//    parentSize);
//    }
//    });
//    }
//    }
//    
//    /**
//     https://www.w3.org/TR/css-flexbox-1/#algo-line-break
//     */
//    static std::vector<ASStackUnpositionedLine> collectChildrenIntoLines(const std::vector<ASStackLayoutSpecItem> &items,
//    const ASStackLayoutSpecStyle &style,
//    const ASSizeRange &sizeRange)
//    {
//    //TODO if infinite max stack size, fast path
//    if (style.flexWrap == ASStackLayoutFlexWrapNoWrap) {
//    return std::vector<ASStackUnpositionedLine> (1, {.items = std::move(items)});
//    }
//    
//    std::vector<ASStackUnpositionedLine> lines;
//    std::vector<ASStackLayoutSpecItem> lineItems;
//    CGFloat lineStackDimensionSum = 0;
//    CGFloat interitemSpacing = 0;
//    
//    for(auto it = items.begin(); it != items.end(); ++it) {
//    const auto &item = *it;
//    const CGFloat itemStackDimension = stackDimension(style.direction, item.layout.size);
//    const CGFloat itemAndSpacingStackDimension = item.child.style.spacingBefore + itemStackDimension + item.child.style.spacingAfter;
//    const BOOL negativeViolationIfAddItem = (ASStackUnpositionedLayout::computeStackViolation(lineStackDimensionSum + interitemSpacing + itemAndSpacingStackDimension, style, sizeRange) < 0);
//    const BOOL breakCurrentLine = negativeViolationIfAddItem && !lineItems.empty();
//    
//    if (breakCurrentLine) {
//    lines.push_back({.items = std::vector<ASStackLayoutSpecItem> (lineItems)});
//    lineItems.clear();
//    lineStackDimensionSum = 0;
//    interitemSpacing = 0;
//    }
//    
//    lineItems.push_back(std::move(item));
//    lineStackDimensionSum += interitemSpacing + itemAndSpacingStackDimension;
//    interitemSpacing = style.spacing;
//    }
//    
//    // Handle last line
//    lines.push_back({.items = std::vector<ASStackLayoutSpecItem> (lineItems)});
//    
//    return lines;
//    }
    
    /**
     Performs the first unconstrained layout of the children, generating the unpositioned items that are then flexed and
     stretched.
     */
    private func layoutItemsAlongUnconstrainedStackDimension(_ children: [RocketComponent], isConcurrent: Bool, sizeRange: SizeRange, parentSize: CGSize, useOptimizedFlexing: Bool) {
        
        let minCrossDimension = crossDimension(sizeRange.min)
        let maxCrossDimension = crossDimension(sizeRange.max)
        
        DispatchQueue.dispatchGroupAsyncIfNeeded(iterationCount: children.count, forced: isConcurrent) { idx in
            let child = children[idx]
            if useOptimizedFlexing && child.layoutProperties.isFlexibleInBothDirections {
                child.layout = Layout(componentId: child.identifier, size: .zero, sublayouts: [])
            } else {
//                child.layout = crossChildLayout(child, minCrossDimension: minCrossDimension, maxCrossDimension: maxCrossDimension, parentSize: parentSize)
            }
        }
//        dispatchApplyIfNeeded(items.size(), concurrent, ^(size_t i) {
//            auto &item = items[i];
//            if (useOptimizedFlexing && isFlexibleInBothDirections(item.child)) {
//                item.layout = [ASLayout layoutWithLayoutElement:item.child.element size:{0, 0}];
//            } else {
//                item.layout = crossChildLayout(item.child,
//                                               style,
//                                               ASDimensionResolve(item.child.style.flexBasis, stackDimension(style.direction, parentSize), 0),
//                                               ASDimensionResolve(item.child.style.flexBasis, stackDimension(style.direction, parentSize), INFINITY),
//                                               minCrossDimension,
//                                               maxCrossDimension,
//                                               parentSize);
//            }
//        });
    }
}
