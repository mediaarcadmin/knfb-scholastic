//
//  SCHStoryInteractionControllerHotSpot.h
//  Scholastic
//
//  Created by Neil Gall on 21/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@interface SCHStoryInteractionControllerHotSpot : SCHStoryInteractionController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {}

- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *pageImageView;

@end
