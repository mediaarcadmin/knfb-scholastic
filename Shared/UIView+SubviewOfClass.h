//
//  UIView+SubviewOfType.h
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (UIView_SubviewOfClass)

// Breadth-first search through a view hierarchy for a subview of a given class.
- (UIView *)subviewOfClass:(Class)subviewClass;

@end
