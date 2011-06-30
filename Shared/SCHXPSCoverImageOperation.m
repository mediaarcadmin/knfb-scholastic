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
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.identifier
                                                                                    inManagedObjectContext:self.localManagedObjectContext];
	NSData *imageData = [xpsProvider coverThumbData];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.identifier];
	
    __block NSString *coverImagePath;
    [self performWithBook:^(SCHAppBook *book) {
        coverImagePath = [[book coverImagePath] retain];
    }];
    
	[imageData writeToFile:coverImagePath atomically:YES];
    [coverImagePath release];
	
    [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
    [self setIsProcessing:NO];
    
    [self endOperation];
}

@end
