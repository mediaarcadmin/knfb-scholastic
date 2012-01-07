//
//  SCHStoriaWelcomeViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 07/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoriaWelcomeViewController.h"

@implementation SCHStoriaWelcomeViewController

@synthesize closeBlock;

- (void)dealloc
{
    [closeBlock release], closeBlock = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (closeBlock) {
        closeBlock();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
