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
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn
                                                                                    inManagedObjectContext:self.localManagedObjectContext];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
    __block NSString *coverImagePath;
    [self withBook:self.isbn perform:^(SCHAppBook *book) {
        coverImagePath = [[book coverImagePath] retain];
    }];
    
	[imageData writeToFile:coverImagePath atomically:YES];
    [coverImagePath release];
	
    [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition forBook:self.isbn];
    [self setBook:self.isbn isProcessing:NO];
    
    [self endOperation];
}

@end
