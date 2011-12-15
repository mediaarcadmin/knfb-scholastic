//
//  SCHAnimationDelegate.m
//  Scholastic
//
//  Created by Neil Gall on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAnimationDelegate.h"

@implementation SCHAnimationDelegate

@synthesize animationDidStartBlock;
@synthesize animationDidStopBlock;

- (void)dealloc 
{
    [animationDidStartBlock release], animationDidStartBlock = nil;
    [animationDidStopBlock release], animationDidStopBlock = nil;
    
    [super dealloc];
}

+ (SCHAnimationDelegate *)animationDelegateWithStartBlock:(SCHAnimationDidStartBlock)startBlock
{
    return [self animationDelegateWithStartBlock:startBlock stopBlock:nil];
}

+ (SCHAnimationDelegate *)animationDelegateWithStopBlock:(SCHAnimationDidStopBlock)stopBlock
{
    return [self animationDelegateWithStartBlock:nil stopBlock:stopBlock];
}

+ (SCHAnimationDelegate *)animationDelegateWithStartBlock:(SCHAnimationDidStartBlock)startBlock stopBlock:(SCHAnimationDidStopBlock)stopBlock
{
    SCHAnimationDelegate *animDelegate = [[SCHAnimationDelegate alloc] init];
    animDelegate.animationDidStartBlock = startBlock;
    animDelegate.animationDidStopBlock = stopBlock;
    return [animDelegate autorelease];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.animationDidStartBlock) {
        self.animationDidStartBlock(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationDidStopBlock) {
        self.animationDidStopBlock(anim, flag);
    }
}

@end
