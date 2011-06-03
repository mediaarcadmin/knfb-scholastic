//
//  SCHShadowBoxView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCHBoxWithShadowView.h"


@implementation SCHBoxWithShadowView

- (void)configure
{
    self.layer.borderWidth = 2;
    self.layer.cornerRadius = 2;
    self.layer.borderColor = [[UIColor colorWithRed:0.133 green:0.243 blue:0.549 alpha:1.] CGColor];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(2, 2);
    self.layer.shadowOpacity = 0.5;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self configure];
    }
    return self;
}

@end
