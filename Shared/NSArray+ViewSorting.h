//
//  NSArray+ViewSorting.h
//  Scholastic
//
//  Created by Neil Gall on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ViewSorting)

// Sort views horizontally left to right, regardless of containing hierarchy. As long
// as all views in the array have a common superview, they will be sorted correctly.
- (NSArray *)viewsSortedHorizontally;

// Sort views vertically top to bottom, regardless of containing hierarchy. As long
// as all views in the array have a common superview, they will be sorted correctly.
- (NSArray *)viewsSortedVertically;

// Sort views in a grid in row-major order. All views must have the same superview.
// The sorted order of overlapping views is undefined.
- (NSArray *)viewsInRowMajorOrder;

@end
