//
//  SCHGradientView.m
//  Scholastic
//
//  Created by Matt Farrugia on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHGradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCHGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

@end
