//
//  SCHReadingView.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingView.h"


@implementation SCHReadingView

@synthesize book;

- (void)dealloc
{
    [book release], book = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame book:(id)aBook
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        book = [aBook retain];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
