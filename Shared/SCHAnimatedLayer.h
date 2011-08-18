//
//  SCHAnimatedLayer.h
//  Scholastic
//
//  Created by Neil Gall on 17/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SCHAnimatedLayer : CALayer {}

@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) NSInteger frameIndex;
@property (nonatomic, assign) NSInteger numberOfFrames;

- (void)animateAllFramesWithDuration:(CFTimeInterval)duration
                         repeatCount:(NSInteger)repeats
                            delegate:(id)delegate;

@end
