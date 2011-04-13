//
//  SCHCustomNavigationBar.m
//  Scholastic
//
//  Created by Gordon Christie on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCustomToolbar.h"


@implementation SCHCustomToolbar

@synthesize barBackgroundImage;

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
    if (self.barBackgroundImage) {
        [self.barBackgroundImage.image drawInRect:rect];
    } else {
        [super drawRect:rect];
    }
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage
{
    self.barBackgroundImage = [[[UIImageView alloc] initWithFrame:self.frame] autorelease];
    self.barBackgroundImage.image = backgroundImage;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
    self.barBackgroundImage = nil;
    [self setNeedsDisplay];
}


@end
