//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCustomNavigationBar.h"

@interface SCHCustomNavigationBar ()

@property (nonatomic, retain) UIColor *originalBackgroundColor;

@end 

@implementation SCHCustomNavigationBar

@synthesize backgroundImage;
@synthesize originalBackgroundColor;

- (id)init {
    self = [super init];
    if (self) {
        self.originalBackgroundColor = nil;
    }
    return self;
}

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
    if (self.backgroundImage != nil) {
        [self.backgroundImage drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

// Save the background image and call setNeedsDisplay to force a redraw
- (void)setBackgroundImage:(UIImage*)newBackgroundImage
{
    [newBackgroundImage retain];
    [backgroundImage release];
    backgroundImage = newBackgroundImage;
    if (self.originalBackgroundColor == nil) {
        self.originalBackgroundColor = self.backgroundColor;
    }
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
- (void)clearBackground
{
    if (self.originalBackgroundColor != nil) {
        self.backgroundColor = self.originalBackgroundColor;        
    }
    self.backgroundImage = nil;
    [self setNeedsDisplay];
}


@end
