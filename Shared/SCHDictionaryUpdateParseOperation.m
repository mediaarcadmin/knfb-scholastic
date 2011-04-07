//
//  SCHDictionaryUpdateParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 07/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryUpdateParseOperation.h"
#import "SCHDictionaryManager.h"
#import "SCHBookManager.h"
#import "SCHDictionaryEntry.h"
#import "SCHDictionaryWordForm.h"


@interface SCHDictionaryUpdateParseOperation ()

@property BOOL executing;
@property BOOL finished;

@end

@implementation SCHDictionaryUpdateParseOperation

@synthesize executing, finished;

- (void) start
{
	if (![self isCancelled]) {
		
        SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];        
        
        [dictManager updateParseEntryTable];
        [dictManager updateParseWordFormTable];
        
        [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateReady];
        dictManager.isProcessing = NO;
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];	
    }
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

@end
