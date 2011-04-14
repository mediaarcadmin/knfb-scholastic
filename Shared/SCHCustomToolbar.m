//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCustomToolbar.h"

@interface SCHCustomToolbar ()

@property (nonatomic, retain) UIColor *originalBackgroundColor;

@end 


@implementation SCHCustomToolbar

@synthesize backgroundImage;
@synthesize originalBackgroundColor;

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
    if (self.backgroundImage) {
        [self.backgroundImage drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)newBackgroundImage
{
    if (backgroundImage != newBackgroundImage) {
        [backgroundImage release];
        backgroundImage = [newBackgroundImage retain];
        if (self.originalBackgroundColor == nil) {
            self.originalBackgroundColor = self.backgroundColor;
        }
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsDisplay];
    }
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
    if (self.originalBackgroundColor != nil) {
        self.backgroundColor = self.originalBackgroundColor;        
    }

    self.backgroundImage = nil;
    [self setNeedsDisplay];
}


@end
