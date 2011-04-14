//
//  SCHReadingView.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingView.h"


@implementation SCHReadingView

@synthesize isbn, delegate;

- (void) dealloc
{
    [isbn release], isbn = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame isbn:(id)aIsbn
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isbn = [aIsbn retain];
        self.opaque = YES;
    }
    return self;
}

// Overridden methods

- (void)jumpToPageAtIndex:(NSUInteger)page animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToPage:animated: not being overridden correctly.");
}

- (void)jumpToNextZoomBlock
{
    // Do nothing
}

- (void)jumpToPreviousZoomBlock
{
    // Do nothing
}

@end
