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

@implementation SCHBookURLRequestOperation

- (void)dealloc {
	[super dealloc];
}

- (void) beginOperation
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlSuccess:) name:kSCHURLManagerSuccess object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlFailure:) name:kSCHURLManagerFailure object:nil];
	
	[[SCHURLManager sharedURLManager] requestURLForISBN:self.isbn];

	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:NO];
	
	return;
	
}

- (void) urlSuccess: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	
	NSString *completedISBN = [userInfo valueForKey:kSCHLibreAccessWebServiceContentIdentifier];

	if ([completedISBN compare:self.isbn] == NSOrderedSame) {
        
        BOOL success = YES;
        
        if (![[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]]) {
	
            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
                                                                    setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceCoverURL]
																  forKey:kSCHAppBookCoverURL];
                
        } else {
            success = NO;
        }
        
        if (![[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL] isEqual:[NSNull null]]) {

            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
                                                                    setValue:[userInfo valueForKey:kSCHLibreAccessWebServiceContentURL]
                                                                      forKey:kSCHAppBookFileURL];
        } else {
            success = NO;
        }
        
        if (success) {
            NSLog(@"Successful URL retrieval for %@!", completedISBN);
            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateNoCoverImage];
        } else {
            NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", userInfo);
            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
        }
		
        [self endOperation];
	}
}

- (void) urlFailure: (NSNotification *) notification
{
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
	NSDictionary *userInfo = [notification userInfo];
	NSString *completedISBN = [userInfo objectForKey:kSCHLibreAccessWebServiceContentIdentifier];
	
	if ([completedISBN compare:self.isbn] == NSOrderedSame) {
		NSLog(@"Failure for ISBN %@", completedISBN);
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];

        [self endOperation];
	}
}

@end