// 
//  SCHHighlight.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHHighlight.h"

#import "SCHLocationText.h"
#import "SCHPrivateAnnotations.h"
#import "UIColor+Extensions.h"
#import "SCHBookRange.h"
#import "SCHBookPoint.h"
#import "SCHWordIndex.h"

// Constants
NSString * const kSCHHighlight = @"SCHHighlight";

@implementation SCHHighlight 

@dynamic Color;
@dynamic EndPage;
@dynamic PrivateAnnotations;
@dynamic Location;

- (UIColor *)HighlightColor
{
    return([UIColor BITcolorWithHexString:self.Color]);
}

- (void)setHighlightColor:(UIColor *)value
{
    self.Color = [value BIThexString];
}

- (NSUInteger)startLayoutPage
{
    return [[self.Location Page] integerValue];
}

- (NSUInteger)startWordOffset
{
    return [[[self.Location WordIndex] Start] integerValue];
}

- (NSUInteger)endLayoutPage
{
    return [self.EndPage integerValue];
}

- (NSUInteger)endWordOffset
{
    return [[[self.Location WordIndex] End] integerValue];
}

@end
