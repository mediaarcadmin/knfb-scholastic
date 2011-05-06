//
//  SCHXPSCoverImageOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 20/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSCoverImageOperation.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"

@implementation SCHXPSCoverImageOperation

#pragma mark - Object Lifecycle

- (void)dealloc {
	[super dealloc];
}

#pragma mark - Book Operation methods
- (void)beginOperation
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
	[imageData writeToFile:[book coverImagePath] atomically:YES];
	
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForLicenseAcquisition];
	[book setProcessing:NO];
    
    [self endOperation];
}

@end
