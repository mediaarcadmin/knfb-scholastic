//
//  NSArray+ViewSorting.m
//  Scholastic
//
//  Created by Neil Gall on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "NSArray+ViewSorting.h"


@implementation NSArray (ViewSorting)

static UIView *commonSuperview(UIView *v1, UIView *v2)
{
    if (v1.superview == nil) {
        return nil;
    }
    for (UIView *v = v2; v != nil; v = v.superview) {
        if (v == v1.superview) {
            return v;
        }
    }
    return commonSuperview(v1.superview, v2);
}

- (NSArray *)viewsSortedHorizontally
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView *v1 = (UIView *)obj1;
        UIView *v2 = (UIView *)obj2;
        UIView *sv = commonSuperview(v1, v2);
        CGPoint c1 = [v1 convertPoint:v1.center toView:sv];
        CGPoint c2 = [v2 convertPoint:v2.center toView:sv];
        if (c1.x < c2.x) return NSOrderedAscending;
        else if (c1.x > c2.x) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}


- (NSArray *)viewsSortedVertically
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UIView *v1 = (UIView *)obj1;
        UIView *v2 = (UIView *)obj2;
        UIView *sv = commonSuperview(v1, v2);
        CGPoint c1 = [v1 convertPoint:v1.center toView:sv];
        CGPoint c2 = [v2 convertPoint:v2.center toView:sv];
        if (c1.y < c2.y) return NSOrderedAscending;
        else if (c1.y > c2.y) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}

- (NSArray *)viewsInRowMajorOrder
{
    return [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGRect r1 = [(UIView *)obj1 frame];
        CGRect r2 = [(UIView *)obj2 frame];
        if (CGRectGetMaxY(r1) < CGRectGetMinY(r2)) return NSOrderedAscending;
        if (CGRectGetMinY(r1) > CGRectGetMaxY(r2)) return NSOrderedDescending;
        if (CGRectGetMaxX(r1) < CGRectGetMinX(r2)) return NSOrderedAscending;
        if (CGRectGetMinX(r1) > CGRectGetMaxX(r2)) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

@end
