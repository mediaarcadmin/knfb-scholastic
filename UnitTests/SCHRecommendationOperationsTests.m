//
//  SCHRecommendationOperationsTests.m
//  Scholastic
//
//  Created by Gordon Christie on 05/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationOperationsTests.h"

@interface SCHRecommendationOperationsTests ()

@property (nonatomic, retain) NSOperationQueue *testingQueue;

@end

@implementation SCHRecommendationOperationsTests

@synthesize testingQueue;

- (void)setUp
{
    self.testingQueue = [[NSOperationQueue alloc] init];
}

- (void)tearDown
{
    self.testingQueue = nil;
    NSLog(@"Tearing down op tests.");
}

- (void)testDownloadCoverJPEGCheck
{
    // TODO
}

- (void)testDownloadCoverOperation
{
//    STAssertTrue(NO, @"Dummy test");
//    STAssertEquals
    
    
/*    
    SCHRecommendationDownloadCoverOperation *downloadOp = [[SCHRecommendationDownloadCoverOperation alloc] init];
    [downloadOp setMainThreadManagedObjectContext:self.managedObjectContext];
    downloadOp.isbn = isbn;
    // the book will be redispatched on completion
    [downloadOp setNotCancelledCompletionBlock:^{
        [self redispatchIsbn:isbn];
    }];
    
    [self.downloadQueue addOperation:downloadOp];
    [downloadOp release];                
*/
    
}

@end
