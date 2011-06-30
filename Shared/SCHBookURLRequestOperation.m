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
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
	
	[[SCHURLManager sharedURLManager] requestURLForISBN:self.identifier.isbn];

	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self setIsProcessing:NO];
}

#pragma mark - SCHURLManager Notifications

- (void)urlSuccess:(NSNotification *) notification
{
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
		
        [self endOperation];
	}
}

- (void)urlFailure:(NSNotification *)notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
    if ([completedISBN isEqual:self.identifier.isbn]) {
		NSLog(@"Failure for ISBN %@", completedISBN);
        [self setProcessingState:SCHBookProcessingStateError];
        [self endOperation];
	}
}

@end