//
//  SCHAnimationDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 03/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

// Takes advantage of the fact the CAAnimation delegates are retained by the animation,
// so an autoreleased object can be used. Passes the owning animation object into the
// start and stop blocks - use this rather than an animation object reference from the
// captured scope to avoid retain loops.

@interface SCHAnimationDelegate : NSObject {}

typedef void (^SCHAnimationDidStartBlock)(CAAnimation *animation);
typedef void (^SCHAnimationDidStopBlock)(CAAnimation *animation, BOOL finished);

@property (nonatomic, copy) SCHAnimationDidStartBlock animationDidStartBlock;
@property (nonatomic, copy) SCHAnimationDidStopBlock animationDidStopBlock;

+ (SCHAnimationDelegate *)animationDelegateWithStartBlock:(SCHAnimationDidStartBlock)startBlock;

+ (SCHAnimationDelegate *)animationDelegateWithStopBlock:(SCHAnimationDidStopBlock)stopBlock;

+ (SCHAnimationDelegate *)animationDelegateWithStartBlock:(SCHAnimationDidStartBlock)startBlock
                                                stopBlock:(SCHAnimationDidStopBlock)stopBlock;

@end
