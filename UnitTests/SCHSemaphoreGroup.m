//
//  SCHSemaphoreGroup.m
//  Scholastic
//
//  Created by Neil Gall on 26/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSemaphoreGroup.h"

@interface SCHSemaphoreGroup ()
@property (nonatomic, assign) dispatch_semaphore_t *semaphores;
@property (nonatomic, assign) volatile BOOL *flags;
@property (nonatomic, assign) NSInteger count;
@end

@implementation SCHSemaphoreGroup

@synthesize semaphores;
@synthesize flags;
@synthesize count;

- (void)dealloc
{
    free(semaphores);
    free((void *)flags);
    [super dealloc];
}

- (id)initWithCount:(NSInteger)aCount
{
    if ((self = [super init])) {
        self.count = aCount;
        self.semaphores = (dispatch_semaphore_t *)malloc(sizeof(dispatch_semaphore_t) * aCount);
        self.flags = (volatile BOOL *)malloc(sizeof(volatile BOOL) * aCount);
        
        for (NSInteger i = 0; i < aCount; ++i) {
            self.semaphores[i] = dispatch_semaphore_create(0);
            self.flags[i] = NO;
        }
    }
    return self;
}

- (void)signal:(NSInteger)index
{
    if (0 <= index && index < self.count) {
        self.flags[index] = YES;
        dispatch_semaphore_signal(self.semaphores[index]);
    }
}

- (void)wait:(NSInteger)index
{
    if (0 <= index && index < self.count) {
        while (!self.flags[index]) {
            dispatch_semaphore_wait(self.semaphores[index], DISPATCH_TIME_FOREVER);
                                    }
                                    }
}

- (void)wait:(NSInteger)index withTimeout:(NSTimeInterval)timeout
{
    if (0 <= index && index < self.count) {
        if (!self.flags[index]) {
            dispatch_semaphore_wait(self.semaphores[index], dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*timeout));
        }
    }
}

- (BOOL)isSignalled:(NSInteger)index
{
    if (0 <= index && index < self.count) {
        return self.flags[index];
    }
    return NO;
}

@end
