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
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    if (self.shelfImage && (self.shelfHeight > 0)) {
        // Drawing code
        CGFloat yOffset = self.shelfInset.height + self.shelfHeight;;
        
        while (yOffset <= rect.size.height) {
            CGRect shelfRect = CGRectMake(self.shelfInset.width, yOffset + self.shelfImage.size.height, CGRectGetWidth(rect) - 2 * self.shelfInset.width, self.shelfImage.size.height);
            
            [self.shelfImage drawInRect:shelfRect];
            yOffset += self.shelfHeight;
        }
    }
}


@end
