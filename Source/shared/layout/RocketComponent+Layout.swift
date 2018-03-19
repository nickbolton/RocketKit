//
//  RocketComponent+Layout.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/16/18.
//

import UIKit

extension RocketComponent {
    
    public func layoutThatFits(_ constrainedSize: SizeRange) -> Layout {
        return layoutThatFits(constrainedSize, parentSize:constrainedSize.max)
    }

    public func layoutThatFits(_ constrainedSize: SizeRange, parentSize: CGSize) -> Layout {
        return blocking { return _layoutThatFits(constrainedSize, parentSize: parentSize) }
    }
    
    private func _layoutThatFits(_ constrainedSize: SizeRange, parentSize: CGSize) -> Layout {
        // If one or multiple layout transitions are in flight it still can happen that layout information is requested
        // on other threads. As the pending and calculated layout to be updated in the layout transition in here just a
        // layout calculation wil be performed without side effect
        if isLayoutTransitionInvalid {
            return calculateLayoutThatFits(constrainedSize, restrictedTo:self.layoutProperties.size, relativeTo:parentSize)
        }
        
        var layout: Layout?
        let version = layoutVersion
        
        if calculatedLayout.isValid(constrainedSize: constrainedSize, parentSize: parentSize, version: version) {
            assert(calculatedLayout.layout != nil, "calculatedLayout.layout should not be nil!")
            layout = calculatedLayout.layout!
        } else if (pendingLayout.isValid(constrainedSize: constrainedSize, parentSize: parentSize, version: version)) {
            assert(pendingLayout.layout != nil, "pendingLayout.layout should not be nil!")
            layout = pendingLayout.layout!
        } else {
            // Create a pending display node layout for the layout pass
            layout = calculateLayoutThatFits(constrainedSize, restrictedTo: layoutProperties.size, relativeTo: parentSize)
//            as_log_verbose(ASLayoutLog(), "Established pending layout for %@ in %s", self, sel_getName(_cmd));
            pendingLayout = CalculatedLayout(layout: layout, constrainedSize: constrainedSize, parentSize: parentSize, version: version)
        }
        
        return layout ?? Layout(componentId: identifier)
    }
    
    private func calculateLayoutThatFits(_ constrainedSize: SizeRange, restrictedTo size: LayoutSize, relativeTo parentSize: CGSize) -> Layout {
        
        let selfAndParentSize = layoutProperties.size.resolve(parentSize: parentSize)
        let resolvedRange = constrainedSize.intersection(with: selfAndParentSize)
        let result = calculateLayoutThatFits(resolvedRange)
        return result

        // We only want one calculateLayout signpost interval per thread.
//        static _Thread_local NSInteger tls_callDepth;
//        as_activity_scope_verbose(as_activity_create("Calculate node layout", AS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT));
//        as_log_verbose(ASLayoutLog(), "Calculating layout for %@ sizeRange %@", self, NSStringFromASSizeRange(constrainedSize));
//        if (tls_callDepth++ == 0) {
//            ASSignpostStart(ASSignpostCalculateLayout);
//        }
//
//        ASSizeRange styleAndParentSize = ASLayoutElementSizeResolve(self.style.size, parentSize);
//        const ASSizeRange resolvedRange = ASSizeRangeIntersect(constrainedSize, styleAndParentSize);
//        ASLayout *result = [self calculateLayoutThatFits:resolvedRange];
//        as_log_verbose(ASLayoutLog(), "Calculated layout %@", result);
//
//        if (--tls_callDepth == 0) {
//            ASSignpostEnd(ASSignpostCalculateLayout);
//        }
//        return result;
    }
    
    private func calculateLayoutThatFits(_ constrainedSize: SizeRange) -> Layout {
        return blocking { return _calculateLayoutThatFits(constrainedSize) }
    }
    
    private func _calculateLayoutThatFits(_ constrainedSize: SizeRange) -> Layout {
        var layout = layoutSpec.layoutThatFits(self, in: constrainedSize)
        layout.position = .zero
        return layout

//    #if YOGA
//    // There are several cases where Yoga could arrive here:
//    // - This node is not in a Yoga tree: it has neither a yogaParent nor yogaChildren.
//    // - This node is a Yoga tree root: it has no yogaParent, but has yogaChildren.
//    // - This node is a Yoga tree node: it has both a yogaParent and yogaChildren.
//    // - This node is a Yoga tree leaf: it has a yogaParent, but no yogaChidlren.
//    YGNodeRef yogaNode = _style.yogaNode;
//    BOOL hasYogaParent = (_yogaParent != nil);
//    BOOL hasYogaChildren = (_yogaChildren.count > 0);
//    BOOL usesYoga = (yogaNode != NULL && (hasYogaParent || hasYogaChildren));
//    if (usesYoga) {
//    // This node has some connection to a Yoga tree.
//    if ([self shouldHaveYogaMeasureFunc] == NO) {
//    // If we're a yoga root, tree node, or leaf with no measure func (e.g. spacer), then
//    // initiate a new Yoga calculation pass from root.
//    ASDN::MutexUnlocker ul(__instanceLock__);
//    as_activity_create_for_scope("Yoga layout calculation");
//    if (self.yogaLayoutInProgress == NO) {
//    ASYogaLog("Calculating yoga layout from root %@, %@", self, NSStringFromASSizeRange(constrainedSize));
//    [self calculateLayoutFromYogaRoot:constrainedSize];
//    } else {
//    ASYogaLog("Reusing existing yoga layout %@", _yogaCalculatedLayout);
//    }
//    ASDisplayNodeAssert(_yogaCalculatedLayout, @"Yoga node should have a non-nil layout at this stage: %@", self);
//    return _yogaCalculatedLayout;
//    } else {
//    // If we're a yoga leaf node with custom measurement function, proceed with normal layout so layoutSpecs can run (e.g. ASButtonNode).
//    ASYogaLog("PROCEEDING past Yoga check to calculate ASLayout for: %@", self);
//    }
//    }
//    #endif /* YOGA */
    
//    // Manual size calculation via calculateSizeThatFits:
//    if (_layoutSpecBlock == NULL && (_methodOverrides & ASDisplayNodeMethodOverrideLayoutSpecThatFits) == 0) {
//    CGSize size = [self calculateSizeThatFits:constrainedSize.max];
//    ASDisplayNodeLogEvent(self, @"calculatedSize: %@", NSStringFromCGSize(size));
//    return [ASLayout layoutWithLayoutElement:self size:ASSizeRangeClamp(constrainedSize, size) sublayouts:nil];
//    }
    
//    // Size calcualtion with layout elements
//    BOOL measureLayoutSpec = _measurementOptions & ASDisplayNodePerformanceMeasurementOptionLayoutSpec;
//    if (measureLayoutSpec) {
//    _layoutSpecNumberOfPasses++;
//    }
    
//    // Get layout element from the node
//    id<ASLayoutElement> layoutElement = [self _locked_layoutElementThatFits:constrainedSize];
//    #if ASEnableVerboseLogging
//    for (NSString *asciiLine in [[layoutElement asciiArtString] componentsSeparatedByString:@"\n"]) {
//    as_log_verbose(ASLayoutLog(), "%@", asciiLine);
//    }
//    #endif
    
    
//    // Certain properties are necessary to set on an element of type ASLayoutSpec
//    if (layoutElement.layoutElementType == ASLayoutElementTypeLayoutSpec) {
//    ASLayoutSpec *layoutSpec = (ASLayoutSpec *)layoutElement;
//
//    #if AS_DEDUPE_LAYOUT_SPEC_TREE
//    NSHashTable *duplicateElements = [layoutSpec findDuplicatedElementsInSubtree];
//    if (duplicateElements.count > 0) {
//    ASDisplayNodeFailAssert(@"Node %@ returned a layout spec that contains the same elements in multiple positions. Elements: %@", self, duplicateElements);
//    // Use an empty layout spec to avoid crashes
//    layoutSpec = [[ASLayoutSpec alloc] init];
//    }
//    #endif
//
//    ASDisplayNodeAssert(layoutSpec.isMutable, @"Node %@ returned layout spec %@ that has already been used. Layout specs should always be regenerated.", self, layoutSpec);
//
//    layoutSpec.isMutable = NO;
//    }
    
    // Manually propagate the trait collection here so that any layoutSpec children of layoutSpec will get a traitCollection
//    {
//    ASDN::SumScopeTimer t(_layoutSpecTotalTime, measureLayoutSpec);
//    ASTraitCollectionPropagateDown(layoutElement, self.primitiveTraitCollection);
//    }
//
//    BOOL measureLayoutComputation = _measurementOptions & ASDisplayNodePerformanceMeasurementOptionLayoutComputation;
//    if (measureLayoutComputation) {
//    _layoutComputationNumberOfPasses++;
//    }
        
//    // Layout element layout creation
////    let layout = layoutThatFits(<#T##constrainedSize: SizeRange##SizeRange#>)
//    ASLayout *layout = ({
//    ASDN::SumScopeTimer t(_layoutComputationTotalTime, measureLayoutComputation);
//    [layoutElement layoutThatFits:constrainedSize];
//    });
//    ASDisplayNodeAssertNotNil(layout, @"[ASLayoutElement layoutThatFits:] should never return nil! %@, %@", self, layout);
//
//    // Make sure layoutElementObject of the root layout is `self`, so that the flattened layout will be structurally correct.
//    BOOL isFinalLayoutElement = (layout.layoutElement != self);
//    if (isFinalLayoutElement) {
//    layout.position = CGPointZero;
//    layout = [ASLayout layoutWithLayoutElement:self size:layout.size sublayouts:@[layout]];
//    }
//    ASDisplayNodeLogEvent(self, @"computedLayout: %@", layout);
//
//    // Return the (original) unflattened layout if it needs to be stored. The layout will be flattened later on (@see _locked_setCalculatedDisplayNodeLayout:).
//    // Otherwise, flatten it right away.
//    if (! [ASDisplayNode shouldStoreUnflattenedLayouts]) {
//    layout = [layout filteredNodeLayoutTree];
//    }
//
//    return layout;
    }

}
