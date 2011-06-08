//
//  UIView+SubviewOfType.m
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "UIView+SubviewOfClass.h"


@implementation UIView (UIView_SubviewOfClass)

- (UIView *)subviewOfClass:(Class)subviewClass
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:subviewClass]) {
            return subview;
        }
        UIView *subsubview = [subview subviewOfClass:subviewClass];
        if (subsubview) {
            return subsubview;
        }
    }
    return nil;
}

@end
