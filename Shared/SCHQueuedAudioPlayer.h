//
//  SCHQueuedAudioPlayer.h
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SCHQueuedAudioPlayer : NSObject <AVAudioPlayerDelegate> {}

typedef NSData * (^SCHQueuedAudioPlayerFetchBlock)(void);

- (void)enqueueAudioTaskWithFetchBlock:(SCHQueuedAudioPlayerFetchBlock)fetchBlock
                synchronizedStartBlock:(dispatch_block_t)startBlock
                  synchronizedEndBlock:(dispatch_block_t)endBlock;

- (void)enqueueGap:(NSTimeInterval)silenceInterval;

- (void)cancelPlaybackExecutingSynchronizedBlocksImmediately:(BOOL)executeBlocks;

- (BOOL)isPlaying;

@end
