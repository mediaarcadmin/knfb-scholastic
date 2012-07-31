//
//  SCHBookURLRequestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookURLRequestOperation.h"
#import "SCHURLManager.h"
#import "SCHLibreAccessConstants.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"
#import "SCHListContentMetadataOperation.h"

@implementation SCHBookURLRequestOperation

#pragma mark - Object Lifecycle

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
    
    __block BOOL validContentMetadataURLs = NO;
    
    // sync call to find out if we have valid contentMetadata URLs
    [self performWithBook:^(SCHAppBook *book) {
        validContentMetadataURLs = [book contentMetadataCoverURLIsValid] && [book contentMetadataFileURLIsValid];
    }];

    if (validContentMetadataURLs) {
        [self performWithBookAndSave:^(SCHAppBook *book) {
            [book setValue:book.ContentMetadataItem.CoverURL forKey:kSCHAppBookCoverURL];
            [book setValue:book.ContentMetadataItem.ContentURL forKey:kSCHAppBookFileURL];                    
        }];
        [self setProcessingState:SCHBookProcessingStateNoCoverImage];
        [self setIsProcessing:NO];                
        [self endOperation];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlCleared:) name:kSCHURLManagerCleared object:nil];
        
        [[SCHURLManager sharedURLManager] requestURLForBook:self.identifier];
    }
}

#pragma mark - SCHURLManager Notifications

- (void)urlSuccess:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self setIsProcessing:NO];        
        [self endOperation];
		return;
	}

	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");

	NSDictionary *userInfo = [notification userInfo];
    SCHBookIdentifier *bookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:userInfo] autorelease];
	
    if ([bookIdentifier isEqual:self.identifier]) {
        
        if ([[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]] || 
            [[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] isEqual:[NSNull null]]) {
            NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
            [self setProcessingState:SCHBookProcessingStateURLsNotPopulated];
        } else {
            
            __block BOOL urlsValid = NO;
            
            [self performWithBookAndSave:^(SCHAppBook *book) {
                SCHListContentMetadataOperation *localOperation = [[SCHListContentMetadataOperation alloc] initWithSyncComponent:nil 
                                                                                                                          result:nil
                                                                                                                        userInfo:nil];
                [localOperation syncContentMetadataItem:userInfo withContentMetadataItem:book.ContentMetadataItem];
                
                if (([book contentMetadataCoverURLIsValid] && [book contentMetadataFileURLIsValid])) {
                    [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] forKey:kSCHAppBookCoverURL];
                    [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] forKey:kSCHAppBookFileURL];
                    urlsValid = YES;
                    
                    // combine resetCoverURLExpiredState and setProcessingState:kSCHAppRecommendationProcessingStateNoCover into this one save
                    [book setUrlExpiredCount:[NSNumber numberWithInteger:0]];
                    NSLog(@"Successful URL retrieval for %@!", bookIdentifier);
                    [book setState:[NSNumber numberWithInt:SCHBookProcessingStateNoCoverImage]];
                }
                [localOperation release];
                
            }];
            
            // check here for invalidity
            if (!urlsValid) {
                [self setCoverURLExpiredState];
            }
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setIsProcessing:NO];        
        [self endOperation];        
	}
}

- (void)urlFailure:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self setIsProcessing:NO];        
        [self endOperation];
		return;
	}

	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	SCHBookIdentifier *completedBookIdentifier = [userInfo objectForKey:kSCHBookIdentifierBookIdentifier];
	
    if ([completedBookIdentifier isEqual:self.identifier]) {
        NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
        [self setProcessingState:SCHBookProcessingStateURLsNotPopulated];

        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setIsProcessing:NO];    
        [self endOperation];        
	}
}

- (void)urlCleared:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self setIsProcessing:NO];        
        [self endOperation];
		return;
	}
    
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");

    [self setProcessingState:SCHBookProcessingStateURLsNotPopulated];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setIsProcessing:NO];    
    [self endOperation];        
}

@end