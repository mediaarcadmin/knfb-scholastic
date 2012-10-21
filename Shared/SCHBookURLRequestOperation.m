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

#pragma mark - Book Operation Methods

- (void)dealloc
{
    [super dealloc];
}

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
    
    NSMutableArray *bookDictionaries = [NSMutableArray arrayWithCapacity:[self.identifiers count]];
    
    for (SCHBookIdentifier *identifier in self.identifiers) {
        __block BOOL validContentMetadataURLs = NO;
        __block NSInteger version = 0;
        
        [self performWithBook:^(SCHAppBook *book) {
            validContentMetadataURLs = [book contentMetadataCoverURLIsValid] && [book contentMetadataFileURLIsValid];
            version = [book.ContentMetadataItem.Version integerValue];
        } forBookWithIdentifier:identifier];
        
        if (validContentMetadataURLs) {
            [self performWithBookAndSave:^(SCHAppBook *book) {
                [book setValue:book.ContentMetadataItem.CoverURL forKey:kSCHAppBookCoverURL];
                [book setValue:book.ContentMetadataItem.ContentURL forKey:kSCHAppBookFileURL];
            } forBookWithIdentifier:identifier];
            [self setProcessingState:SCHBookProcessingStateNoCoverImage forBookWithIdentifier:identifier];
        } else {
            NSDictionary *bookItem = [NSDictionary dictionaryWithObjectsAndKeys:identifier, kURLManagerBookIdentifier, version, kURLManagerVersion, nil];
            [bookDictionaries addObject:bookItem];
        }
    }
        

    if ([bookDictionaries count] == 0) {
        [self endOperation];
    } else {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchComplete:) name:kSCHURLManagerBatchComplete object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlCleared:) name:kSCHURLManagerCleared object:nil];

        [[SCHURLManager sharedURLManager] requestURLForBooks:bookDictionaries];
        
    }
}

#pragma mark - SCHURLManager Notifications

- (void)batchComplete:(NSNotification *)notification
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");
    
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];
		return;
	}

    NSDictionary *userInfo = [notification userInfo];
    NSArray *failureURLs = [userInfo objectForKey:kSCHURLManagerFailure];
    NSArray *successURLs = [userInfo objectForKey:kSCHURLManagerSuccess];
    NSError *urlsError   = [userInfo objectForKey:kSCHURLManagerError];
    
    if (urlsError) {
        NSUInteger successCount = [successURLs count];
        NSUInteger failureCount = [failureURLs count];
        
        NSLog(@"Error when requesting URLS. Received %d success and %d failures", successCount, failureCount);
        
        if ((successCount + failureCount) == 0) {
            // If we get an error from the service with no identifying dictionaries we fail this operation (and any other operations waiting on URLs)
            for (SCHBookIdentifier *identifier in self.identifiers) {
                [self setProcessingState:SCHBookProcessingStateURLsNotPopulated forBookWithIdentifier:identifier];
            }
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self endOperation];
        }
    }
    BOOL matchedResults = NO;
    
    for (NSDictionary *contentMetadataDictionary in successURLs) {
        SCHBookIdentifier *succeeededBookIdentifier = [[[SCHBookIdentifier alloc] initWithObject:contentMetadataDictionary] autorelease];

        if ([self.identifiers containsObject:succeeededBookIdentifier]) {
            
            if ([[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceCoverURL] isEqual:[NSNull null]] ||
                [[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceContentURL] isEqual:[NSNull null]]) {
                NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", contentMetadataDictionary);
                [self setProcessingState:SCHBookProcessingStateURLsNotPopulated forBookWithIdentifier:succeeededBookIdentifier];
            } else {
                
                __block BOOL urlsValid = NO;
                
                [self performWithBookAndSave:^(SCHAppBook *book) {
                    SCHListContentMetadataOperation *localOperation = [[SCHListContentMetadataOperation alloc] initWithSyncComponent:nil
                                                                                                                              result:nil
                                                                                                                            userInfo:nil];
                    [localOperation syncContentMetadataItem:contentMetadataDictionary withContentMetadataItem:book.ContentMetadataItem];
                    
                    if (([book contentMetadataCoverURLIsValid] && [book contentMetadataFileURLIsValid])) {
                        [book setValue:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceCoverURL] forKey:kSCHAppBookCoverURL];
                        [book setValue:[contentMetadataDictionary valueForKey:kSCHLibreAccessWebServiceContentURL] forKey:kSCHAppBookFileURL];
                        urlsValid = YES;
                        
                        // combine resetCoverURLExpiredState and setProcessingState:kSCHAppRecommendationProcessingStateNoCover into this one save
                        [book setUrlExpiredCount:[NSNumber numberWithInteger:0]];
                        NSLog(@"Successful URL retrieval for %@", succeeededBookIdentifier);
                        [book setState:[NSNumber numberWithInt:SCHBookProcessingStateNoCoverImage]];
                    }
                    [localOperation release];
                    
                } forBookWithIdentifier:succeeededBookIdentifier];
                
                // check here for invalidity
                if (!urlsValid) {
                    [self setCoverURLExpiredStateForBookWithIdentifier:succeeededBookIdentifier];
                }
            }

            matchedResults = YES;
        }
    }
    
    for (NSDictionary *contentMetadataDictionary in failureURLs) {
        SCHBookIdentifier *failedBookIdentifier = [contentMetadataDictionary objectForKey:kSCHBookIdentifierBookIdentifier];
        
        if ([self.identifiers containsObject:failedBookIdentifier]) {
            NSLog(@"Warning: book URL request was missing cover and/or content URL: %@", contentMetadataDictionary);
            [self setProcessingState:SCHBookProcessingStateURLsNotPopulated forBookWithIdentifier:failedBookIdentifier];
            matchedResults = YES;
        }
    }
    
    if (matchedResults) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self endOperation];
    }
}

- (void)urlCleared:(NSNotification *)notification
{
    if (self.isCancelled) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];        
        [self endOperation];
		return;
	}
    
	NSAssert([NSThread currentThread] == [NSThread mainThread], @"Notification is not fired on the main thread!");

    for (SCHBookIdentifier *identifier in self.identifiers) {
        [self setProcessingState:SCHBookProcessingStateURLsNotPopulated forBookWithIdentifier:identifier];
    }
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endOperation];        
}

@end