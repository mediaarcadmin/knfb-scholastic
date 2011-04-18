//
//  SCHBookShelfGridShelvesView.m
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridShelvesView.h"


@implementation SCHBookShelfGridShelvesView

@synthesize shelfHeight;
@synthesize shelfInset;
@synthesize shelfImage;

- (void)dealloc
{
    [shelfImage release], shelfImage = nil;
    [super dealloc];
}

- (void)setShelfImage:(UIImage *)aShelfImage
{
    [aShelfImage retain];
    [shelfImage release];
    shelfImage = aShelfImage;
    
    [self setNeedsDisplay];
}

- (void)setShelfInset:(CGSize)inset
{
    shelfInset = inset;
    
    [self setNeedsDisplay];
}

- (void)setShelfHeight:(CGFloat)height
{
    shelfHeight = height;
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.shelfImage && (self.shelfHeight > 0)) {
        // Drawing code
        CGFloat yOffset = self.shelfInset.height;
        
        while (yOffset <= rect.size.height) {
            [self.shelfImage drawAtPoint:CGPointMake(self.shelfInset.width, yOffset)];
            yOffset += self.shelfInset.height + self.shelfHeight;
        }
    }
}


@end
