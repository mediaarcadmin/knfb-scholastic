//
//  SCH3DView.m
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCH3DView.h"

@implementation SCH3DView

+ (Class)layerClass
{
    return [CATransformLayer class];
}

// make sure the subviews are the same size as the view
- (void)layoutSubviews
{
    for (CALayer *sublayer in [self.layer sublayers]){
        sublayer.frame = (CGRect){ CGPointZero, self.bounds.size };
    }
}

@end
