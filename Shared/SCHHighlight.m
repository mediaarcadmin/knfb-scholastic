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

@interface SCHHighlight (PrimitiveAccessors)

@property (nonatomic, retain) NSString *primitiveColor;

@end

@implementation SCHHighlight 

@dynamic Color;
@dynamic EndPage;
@dynamic PrivateAnnotations;
@dynamic LocationText;

- (UIColor *)Color
{
    [self willAccessValueForKey:@"Color"];
    UIColor *tmpValue = [UIColor BITcolorWithHexString:[self primitiveColor]];
    [self didAccessValueForKey:@"Color"];
    return(tmpValue);
}

- (void)setColor:(UIColor *)value
{
    [self willChangeValueForKey:@"Color"];
    [self setPrimitiveColor:[value BIThexString]];
    [self didChangeValueForKey:@"Color"];
}

@end
