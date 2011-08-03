//
//  SCHBookShelfShadowsView.m
//  Scholastic
//
//  Created by Matt Farrugia on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfShadowsView.h"


@implementation SCHBookShelfShadowsView

- (void)setupShadows
{
    CGRect viewBounds = self.bounds;
    
    UIImageView *topLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-topleft-shadow"]];
    [topLeft setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin];
    [topLeft setFrame:CGRectMake(0, 0, topLeft.image.size.width, topLeft.image.size.height)];
    
    
    UIImageView *topRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-topright-shadow"]];
    [topRight setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin];
    [topRight setFrame:CGRectMake(CGRectGetMaxX(viewBounds) - topRight.image.size.width, 0, topRight.image.size.width, topRight.image.size.height)];
   
    
    UIImageView *top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-top-shadow"]];
    [top setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [top setFrame:CGRectMake(topLeft.image.size.width, 0, CGRectGetWidth(viewBounds) - topLeft.image.size.width - topRight.image.size.width, top.image.size.height)];
    
    
    UIImageView *bottomLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-bottomleft-shadow"]];
    [bottomLeft setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin];
    [bottomLeft setFrame:CGRectMake(0, CGRectGetHeight(viewBounds) - topRight.image.size.height, topRight.image.size.width, topRight.image.size.height)];
    
    
    UIImageView *left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-left-shadow"]];
    [left setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
    [left setFrame:CGRectMake(0, topLeft.image.size.height, left.image.size.width, CGRectGetHeight(viewBounds) - topLeft.image.size.height - bottomLeft.image.size.height)];
    
    
    UIImageView *bottomRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-bottomright-shadow"]];
    [bottomRight setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin];
    [bottomRight setFrame:CGRectMake(CGRectGetMaxX(viewBounds) - bottomRight.image.size.width, CGRectGetHeight(viewBounds) - bottomRight.image.size.height, bottomRight.image.size.width, bottomRight.image.size.height)];
    
    
    UIImageView *right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-right-shadow"]];
    [right setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
    [right setFrame:CGRectMake(CGRectGetMaxX(viewBounds) - right.image.size.width, topRight.image.size.height, right.image.size.width, CGRectGetHeight(viewBounds) - bottomRight.image.size.height - topRight.image.size.height)];
    
    
    UIImageView *bottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-bottom-shadow"]];
    [bottom setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [bottom setFrame:CGRectMake(bottomLeft.image.size.width, CGRectGetHeight(viewBounds) - bottom.image.size.height, CGRectGetWidth(viewBounds) - bottomLeft.image.size.width - bottomRight.image.size.width, bottom.image.size.height)];
    
    [self addSubview:topLeft];
    [self addSubview:topRight];
    [self addSubview:top];
    [self addSubview:bottomLeft];
    [self addSubview:left];
    [self addSubview:bottomRight];
    [self addSubview:right];
    [self addSubview:bottom];
    
#if 0
    [topLeft setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [topRight setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [top setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [bottomLeft setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [left setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [bottomRight setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [right setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
    [bottom setBackgroundColor:[UIColor colorWithRed:rand()%1000/1000.0f green:rand()%1000/1000.0f blue:rand()%1000/1000.0f alpha:1]];
#endif
    
    [topLeft release];
    [topRight release];
    [top release];
    [bottomLeft release];
    [left release];
    [bottomRight release];
    [right release];
    [bottom release];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupShadows];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupShadows];
    }
    return self;
}



@end
