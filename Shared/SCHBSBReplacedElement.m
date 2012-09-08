//
//  SCHBSBReplacedElementPlaceholder
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElement.h"
#import <libEucalyptus/THRoundRects.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@implementation SCHBSBReplacedElement

@synthesize scaleFactor;
@synthesize delegate;
@synthesize nodeId;
@synthesize font;

- (void)dealloc
{
    delegate = nil;
    [nodeId release], nodeId = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        scaleFactor = 1;
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    return CGSizeZero; // Subclasses should override with something more sensisble
}

- (UIFont *)font
{
    if (font) {
        return font;
    }
    
    return [UIFont systemFontOfSize:17];
}

- (void)renderInRect:(CGRect)rect inContext:(CGContextRef)context
{
    // noop
}

@end
