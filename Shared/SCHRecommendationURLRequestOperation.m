//
//  SCHRecommendationURLRequestOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationURLRequestOperation.h"
#import "SCHURLManager.h"
#import "SCHLibreAccessConstants.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHBookIdentifier.h"

@implementation SCHRecommendationURLRequestOperation

- (void)beginOperation
{
    // Following Dave Dribins pattern 
    // http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(beginOperation) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    
    self.executing = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    
    NSMutableArray *recommendationIsbns = [NSMutableArray arrayWithCapacity:[self.isbns count]];
    
    for (NSString *isbn in self.isbns) {
        __block NSString *coverURL = nil;
        __block BOOL recommendationFound = NO;
        
        [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
            if (item) {
                recommendationFound = YES;
                coverURL = [item.CoverURL copy];
            }
        } forRecommendationWithIsbn:isbn];
        
        [coverURL autorelease];
        
        BOOL coverUrlIsValid = [SCHRecommendationManager urlIsValid:coverURL];

        if (coverUrlIsValid) {
            [self setProcessingState:kSCHAppRecommendationProcessingStateNoCover forRecommendationWithIsbn:isbn];
        } else if (!recommendationFound) {
            [self setProcessingState:kSCHAppRecommendationProcessingStateUnspecifiedError forRecommendationWithIsbn:isbn];
        } else {
            [recommendationIsbns addObject:isbn];
        }
    }
    
    if ([recommendationIsbns count] == 0) {
        [self endOperation];
    } else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchComplete:) name:kSCHURLManagerBatchComplete object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlCleared:) name:kSCHURLManagerCleared object:nil];
        
        [[SCHURLManager sharedURLManager] requestURLForRecommendations:recommendationIsbns];
        
    }
}

#pragma mark - SCHURLManager Notifications

- (void)batchComplete:(NSNotification *)notification
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
    
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];
		return;
	}
    
    NSDictionary *userInfo = [notification userInfo];
    NSArray *failureURLs = [userInfo objectForKey:kSCHURLManagerFailure];
    NSArray *successURLs = [userInfo objectForKey:kSCHURLManagerSuccess];
    NSError *urlsError   = [userInfo objectForKey:kSCHURLManagerError];
    
    if (urlsError) {
        NSUInteger successCount = [successURLs count];
        NSUInteger failureCount = [failureURLs count];
        
        NSLog(@"Error when requesting URLs. Received %d success and %d failures", successCount, failureCount);
        
        if ((successCount + failureCount) == 0) {
            // If we get an error from the service with no identifying isbns we fail this operation (and any other operations waiting on URLs)
            for (NSString *isbn in self.isbns) {
                [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated forRecommendationWithIsbn:isbn];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self endOperation];
        }
    }
    
    BOOL matchedResults = NO;
    
    for (NSDictionary *contentMetadataDictionary in successURLs) {
        NSString *succeeededIsbn = [contentMetadataDictionary objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
        
        if ([self.isbns containsObject:succeeededIsbn]) {
            
            if ([[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]]) {
                NSLog(@"Warning: recommendation URL request was missing cover URL: %@", contentMetadataDictionary);
                [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated forRecommendationWithIsbn:succeeededIsbn];
            } else {
                
                NSString *coverURL = [contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceCoverURL];
                
                BOOL coverUrlIsValid = NO;
                
                if ([SCHRecommendationManager urlIsValid:coverURL]) {
                    coverUrlIsValid = YES;
                }
                
                if (!coverUrlIsValid) {
                    [self setCoverURLExpiredStateForRecommendationWithIsbn:self.isbn];
                } else {
                    [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
                        [item setCoverURL:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceCoverURL]];
                        [item setAuthor:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceAuthor]];
                        [item setTitle:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceTitle]];
                        [item setAverageRating:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceAverageRating]];
                        // combine resetCoverURLExpiredState and setProcessingState:kSCHAppRecommendationProcessingStateNoCover into this one save
                        [item setState:[NSNumber numberWithInt:kSCHAppRecommendationProcessingStateNoCover]];
                        [item setCoverURLExpiredCount:[NSNumber numberWithInteger:0]];
                    } forRecommendationWithIsbn:succeeededIsbn];
                }
            }
            
            matchedResults = YES;

        }
    }
    
    for (SCHBookIdentifier *failedBookIdentifier in failureURLs) {
        
        NSString *failedIsbn = [failedBookIdentifier isbn];
        
        if ([self.isbns containsObject:failedIsbn]) {

            //NSInteger errorCode = [[contentMetadataDictionary objectForKey:kSCHAppRecommendationItemErrorCode] intValue];
            
            //if (errorCode == 75) {
                NSLog(@"Warning: recommendation URL request invalid for isbn %@", failedIsbn);
                [self setProcessingState:kSCHAppRecommendationProcessingStateInvalidRecommendation forRecommendationWithIsbn:failedIsbn];
            //} else {
              //  NSLog(@"Warning: recommendation URL request failed %@", contentMetadataDictionary);
                //[self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated forRecommendationWithIsbn:failedIsbn];
            //}
            
            matchedResults = YES;
        }
    }
    
    if (matchedResults) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];
    }
}

- (void)urlCleared:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];
		return;
	}
    
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
    
    for (NSString *isbn in self.isbns) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated forRecommendationWithIsbn:isbn];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endOperation];
}

@end
