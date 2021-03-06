//
//  SCHQueuedAudioPlayer.h
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SCHQueuedAudioPlayer : NSObject <AVAudioPlayerDelegate> {}

// dispatch queue to execute synchronized blocks on; default is main queue
@property (nonatomic, assign) dispatch_queue_t synchronizedBlockQueue;

typedef NSData * (^SCHQueuedAudioPlayerFetchBlock)(void);

- (void)enqueueAudioTaskWithFetchBlock:(SCHQueuedAudioPlayerFetchBlock)fetchBlock
                synchronizedStartBlock:(dispatch_block_t)startBlock
                  synchronizedEndBlock:(dispatch_block_t)endBlock;

- (void)enqueueAudioTaskWithFetchBlock:(SCHQueuedAudioPlayerFetchBlock)fetchBlock
                synchronizedStartBlock:(dispatch_block_t)startBlock
                  synchronizedEndBlock:(dispatch_block_t)endBlock
                    requiresEmptyQueue:(BOOL)requiresEmpty;

- (void)enqueueGap:(NSTimeInterval)silenceInterval;

- (void)cancelPlaybackExecutingSynchronizedBlocks:(BOOL)executeBlocks
                          beforeCompletionHandler:(dispatch_block_t)completion;

- (BOOL)isPlaying;

@end
