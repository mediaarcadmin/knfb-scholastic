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

@interface SCHRecommendationURLRequestOperation()

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

@end

@implementation SCHRecommendationURLRequestOperation

@synthesize bookIdentifier;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
    [bookIdentifier release], bookIdentifier = nil;
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
    
    __block BOOL coverUrlIsValid = NO;
    
    [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
        [SCHRecommendationManager urlIsValid:item.CoverURL];
    }];
    
    if (coverUrlIsValid) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateNoCover];
        [self endOperation];
    } else if (!self.isbn) {
        [self setProcessingState:kSCHAppRecommendationProcessingStateError];
        [self endOperation];
    } else {
        
        self.bookIdentifier = [[[SCHBookIdentifier alloc] initWithISBN:self.isbn DRMQualifier:[NSNumber numberWithInteger:kSCHDRMQualifiersFullWithDRM]] autorelease];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        
        [[SCHURLManager sharedURLManager] requestURLForBook:self.bookIdentifier];
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
    SCHBookIdentifier *aBookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:userInfo] autorelease];
	
    if ([aBookIdentifier isEqual:self.bookIdentifier]) {
        
        if ([[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]]) {
            NSLog(@"Warning: recommendation URL request was missing cover URL: %@", userInfo);
            [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
        } else {
            
            __block BOOL coverUrlIsValid = NO;
            
            [self performWithRecommendationAndSave:^(SCHAppRecommendationItem *item) {
                
                NSString *coverURL = [userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL];
                
                if ([SCHRecommendationManager urlIsValid:coverURL]) {
                    [item setCoverURL:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL]];
                    [item setAuthor:[userInfo valueForKey:kSCHLibreAccessWebServiceAuthor]];
                    [item setTitle:[userInfo valueForKey:kSCHLibreAccessWebServiceTitle]];
                    [item setAverageRating:[userInfo valueForKey:kSCHLibreAccessWebServiceAverageRating]];
                    
                    coverUrlIsValid = YES;
                }                
            }];
            
            // check here for invalidity
            if (!coverUrlIsValid) {
                NSLog(@"Warning: URLs from the server were already invalid for %@!", aBookIdentifier);
                [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
            } else {
                NSLog(@"Successful URL retrieval for %@!", aBookIdentifier);
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
	SCHBookIdentifier *completedBookIdentifier = [userInfo objectForKey:kSCHBookIdentifierBookIdentifier];
	
    if ([completedBookIdentifier isEqual:self.bookIdentifier]) {
        NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
        [self setProcessingState:kSCHAppRecommendationProcessingStateURLsNotPopulated];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];        
	}
}

@end
