//
//  SCHHitTestExtendingView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHHitTestExtendingView.h"

@implementation SCHHitTestExtendingView

@synthesize forwardedView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.forwardedView;
}

- (void)dealloc
{
    [forwardedView release], forwardedView = nil;
    [super dealloc];
}

@end
