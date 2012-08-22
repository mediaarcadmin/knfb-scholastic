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

- (void)dealloc
{
    [super dealloc];
}
#pragma mark - Book Operation Methods

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
    
    __block NSString *coverURL = nil;
    
    [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
        coverURL = [item.CoverURL copy];
    }];
    
    [coverURL autorelease];
    
    BOOL coverUrlIsValid = [SCHRecommendationManager urlIsValid:coverURL];
    
    if (coverUrlIsValid) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateNoCover];
        [self endOperation];
    } else if (!self.isbn) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateUnspecifiedError];
        [self endOperation];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlCleared:) name:kSCHURLManagerCleared object:nil];        
        
        [[SCHURLManager sharedURLManager] requestURLForRecommendation:self.isbn];
    }
}

#pragma mark - SCHURLManager Notifications

- (void)urlSuccess:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self endOperation];
		return;
	}
    
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
    
	NSDictionary *userInfo = [notification userInfo];
    NSString *completedIsbn = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
    if ([completedIsbn isEqualToString:self.isbn]) {
        
        if ([[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]]) {
            NSLog(@"Warning: recommendation URL request was missing cover URL: %@", userInfo);
            [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
        } else {
            
            NSString *coverURL = [userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL];
            
            BOOL coverUrlIsValid = NO;
            
            if ([SCHRecommendationManager urlIsValid:coverURL]) {                
                coverUrlIsValid = YES;
            } 
            
            if (!coverUrlIsValid) {
                [self setCoverURLExpiredState];
            } else {
                NSLog(@"Successful URL retrieval for %@!", completedIsbn);
                [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
                    [item setCoverURL:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL]];
                    [item setAuthor:[userInfo valueForKey:kSCHLibreAccessWebServiceAuthor]];
                    [item setTitle:[userInfo valueForKey:kSCHLibreAccessWebServiceTitle]];
                    [item setAverageRating:[userInfo valueForKey:kSCHLibreAccessWebServiceAverageRating]];
                    // combine resetCoverURLExpiredState and setProcessingState:kSCHAppRecommendationProcessingStateNoCover into this one save
                    [item setState:[NSNumber numberWithInt:kSCHAppRecommendationProcessingStateNoCover]];
                    [item setCoverURLExpiredCount:[NSNumber numberWithInteger:0]];
                }];
                
            }
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];        
	}
}

- (void)urlFailure:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self endOperation];
		return;
	}
    
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedIsbn = [userInfo objectForKey:kSCHAppRecommendationItemIsbn];
	
    if ([completedIsbn isEqualToString:self.isbn]) {
        NSInteger errorCode = [[userInfo objectForKey:kSCHAppRecommendationItemErrorCode] intValue];

        if (errorCode == 75) {
            [self setProcessingState:kSCHAppRecommendationProcessingStateInvalidRecommendation];
        } else {
            NSLog(@"Warning: recommendation URL request failed %@", userInfo);
            [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
        }
        
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
	
    [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endOperation];        
}

@end
