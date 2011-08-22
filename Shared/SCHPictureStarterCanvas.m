//
//  SCHPictureStarterCanvas.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterCanvas.h"

@implementation SCHPictureStarterCanvas

@synthesize backgroundImage;

- (void)dealloc
{
    [backgroundImage release], backgroundImage = nil;
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, self.bounds, [self.backgroundImage CGImage]);
}

@end
