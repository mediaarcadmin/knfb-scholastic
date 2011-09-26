//
//  SCHBookURLRequestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookURLRequestOperation.h"
#import "SCHURLManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHAppBook.h"
#import "SCHBookIdentifier.h"

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
        [self endOperation];
        [self setIsProcessing:NO];        
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
        
        [[SCHURLManager sharedURLManager] requestURLForBook:self.identifier];
    }
}

#pragma mark - SCHURLManager Notifications

- (void)urlSuccess:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.isCancelled) {
        [self endOperation];
        [self setIsProcessing:NO];
		return;
	}

	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	
	NSString *completedISBN = [userInfo valueForKey:kSCHLibreAccessWebServiceContentIdentifier];

    if ([completedISBN isEqual:self.identifier.isbn]) {
        
        BOOL success = YES;
        
        if (![[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]]) {
	
            [self performWithBook:^(SCHAppBook *book) {
                [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] forKey:kSCHAppBookCoverURL];
            }];
                
        } else {
            success = NO;
        }
        
        if (![[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] isEqual:[NSNull null]]) {

            [self performWithBook:^(SCHAppBook *book) {
                [book setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] forKey:kSCHAppBookFileURL];
            }];
        } else {
            success = NO;
        }
        
        if (success) {
            NSLog(@"Successful URL retrieval for %@!", completedISBN);
            [self setProcessingState:SCHBookProcessingStateNoCoverImage];
        } else {
            NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
            [self setProcessingState:SCHBookProcessingStateError];
        }
	}
    [self endOperation];
    [self setIsProcessing:NO];    
}

- (void)urlFailure:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.isCancelled) {
        [self endOperation];
        [self setIsProcessing:NO];
		return;
	}

	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	SCHBookIdentifier *completedBookIdentifier = [userInfo objectForKey:kSCHBookIdentifierBookIdentifier];
	
    if ([completedBookIdentifier isEqual:self.identifier]) {
        NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
        [self setProcessingState:SCHBookProcessingStateURLsNotPopulated];
	}
    [self endOperation];
    [self setIsProcessing:NO];
}

@end