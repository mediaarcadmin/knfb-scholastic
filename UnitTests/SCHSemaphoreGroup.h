//
//  SCHSemaphoreGroup.h
//  Scholastic
//
//  Created by Neil Gall on 26/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHSemaphoreGroup : NSObject {}

- (id)initWithCount:(NSInteger)count;

- (void)signal:(NSInteger)index;
- (void)wait:(NSInteger)index;
- (void)wait:(NSInteger)index withTimeout:(NSTimeInterval)timeout;
- (BOOL)isSignalled:(NSInteger)index;

@end
