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
#import "SCHAppRecommendationItem.h"
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
    
    __block NSString *coverURL;
    
    [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
        coverURL = [item.CoverURL retain];
    }];
    
    [coverURL autorelease];
    
    BOOL coverUrlIsValid = [SCHRecommendationManager urlIsValid:coverURL];
    
    if (coverUrlIsValid) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateNoCover];
        [self endOperation];
    } else if (!self.isbn) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateError];
        [self endOperation];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        
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
                NSLog(@"Warning: URLs from the server were already invalid for %@!", completedIsbn);
                [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
            } else {
                NSLog(@"Successful URL retrieval for %@!", completedIsbn);
                [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
                    [item setCoverURL:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL]];
                    [item setAuthor:[userInfo valueForKey:kSCHLibreAccessWebServiceAuthor]];
                    [item setTitle:[userInfo valueForKey:kSCHLibreAccessWebServiceTitle]];
                    [item setAverageRating:[userInfo valueForKey:kSCHLibreAccessWebServiceAverageRating]];
                }];
                
                [self setProcessingState:kSCHAppRecommendationProcessingStateNoCover];
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
        NSLog(@"Warning: recommendation URL request failed %@", userInfo);
        [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];        
	}
}

@end
