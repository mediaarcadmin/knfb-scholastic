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
#import "SCHBookshelfSyncComponent.h"

@implementation SCHBookURLRequestOperation

#pragma mark - Object Lifecycle

- (void)dealloc 
{
	[super dealloc];
}

#pragma mark - Book Operation Methods

- (void)beginOperation
{
    __block BOOL haveContentURL = NO;

    // Following Dave Dribins pattern 
    // http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(beginOperation) withObject:nil waitUntilDone:NO];
        return;
    }

    // sync call to find out if we have a contentURL
    [self performWithBook:^(SCHAppBook *book) {
        haveContentURL = book.ContentMetadataItem.ContentURL != nil;
    }];

    [self performWithBookAndSave:^(SCHAppBook *book) {
        if (haveContentURL == YES) {
            [book setValue:book.ContentMetadataItem.CoverURL forKey:kSCHAppBookCoverURL];
            [book setValue:book.ContentMetadataItem.ContentURL forKey:kSCHAppBookFileURL];                    
        }
    }];

    if (haveContentURL == YES) {
        [self setProcessingState:SCHBookProcessingStateNoCoverImage];
        [self setIsProcessing:NO];                
        [self endOperation];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        
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
            [self setProcessingState:SCHBookProcessingStateError];
        } else {
            
            __block BOOL urlsAlreadyExpired = NO;
            
            [self performWithBookAndSave:^(SCHAppBook *book) {
                SCHBookshelfSyncComponent *localComponent = [[SCHBookshelfSyncComponent alloc] init];
                [localComponent syncContentMetadataItem:userInfo withContentMetadataItem:book.ContentMetadataItem];
                [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] forKey:kSCHAppBookCoverURL];
                [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] forKey:kSCHAppBookFileURL];
                [localComponent release];
                
                if ([book bookCoverURLHasExpired] || [book bookFileURLHasExpired]) {
                    urlsAlreadyExpired = YES;
                }
            }];
            
            // check here for expiry
            if (urlsAlreadyExpired) {
                NSLog(@"Warning: URLs from the server have already expired for %@!", bookIdentifier);
                [self setProcessingState:SCHBookProcessingStateError];
            } else {
                NSLog(@"Successful URL retrieval for %@!", bookIdentifier);
                [self setProcessingState:SCHBookProcessingStateNoCoverImage];
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

@end