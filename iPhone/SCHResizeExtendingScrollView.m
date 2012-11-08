//
//  SCHResizeExtendingScrollView.m
//  Scholastic
//
//  Created by John S. Eddie on 08/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHResizeExtendingScrollView.h"

#import "SCHResizeExtendingScrollViewDelegate.h"

@implementation SCHResizeExtendingScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];

    if ([self.delegate conformsToProtocol:@protocol(SCHResizeExtendingScrollViewDelegate)] == YES) {
        [(id)self.delegate resizeExtendingScrollViewDidLayoutSubviews:self];
    }
}

@end
