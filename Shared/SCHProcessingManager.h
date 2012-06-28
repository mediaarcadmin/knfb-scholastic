//
//  SCHProcessingManager.h
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHAsyncBookCoverImageView;
@class SCHAppBook;
@class SCHBookIdentifier;
@class NSManagedObjectContext;

typedef enum {
    SCHBookProcessingStateNotEnoughStorageError      = -7,
    SCHBookProcessingStateURLsNotPopulated           = -6,
    SCHBookProcessingStateDownloadFailed             = -5,
    SCHBookProcessingStateUnableToAcquireLicense     = -4,
    SCHBookProcessingStateCachedCoverError           = -3,
	SCHBookProcessingStateError                      = -2,
	SCHBookProcessingStateBookVersionNotSupported    = -1,
	SCHBookProcessingStateNoURLs                     = 0,
	SCHBookProcessingStateNoCoverImage               = 1,
	SCHBookProcessingStateReadyForBookFileDownload   = 2,
	SCHBookProcessingStateDownloadStarted            = 3,
	SCHBookProcessingStateDownloadPaused             = 4,
	SCHBookProcessingStateReadyForLicenseAcquisition = 5,
	SCHBookProcessingStateReadyForRightsParsing      = 6,
	SCHBookProcessingStateReadyForAudioInfoParsing   = 7,
	SCHBookProcessingStateReadyForTextFlowPreParse   = 8,
    SCHBookProcessingStateReadyForSmartZoomPreParse  = 9,
	SCHBookProcessingStateReadyForPagination         = 10,
	SCHBookProcessingStateReadyToRead                = 11,
} SCHBookCurrentProcessingState;

// Constants
extern NSString * const kSCHProcessingManagerConnectionIdle;
extern NSString * const kSCHProcessingManagerConnectionBusy;

@interface SCHProcessingManager : NSObject {}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// shared manager instance
// FIXME: notes on duties - registers for events etc.
+ (SCHProcessingManager *)sharedProcessingManager;

// user selection method
- (void)userSelectedBookWithIdentifier:(SCHBookIdentifier *)identifier;
- (void)userRequestedRetryForBookWithIdentifier:(SCHBookIdentifier *)identifier;

- (BOOL)forceReDownloadForBookWithIdentifier:(SCHBookIdentifier *)identifier;

// methods for processing
- (BOOL)identifierIsProcessing:(SCHBookIdentifier *)identifier;
- (void)setProcessing:(BOOL)processing forIdentifier:(SCHBookIdentifier *)identifier;

// stop all the processing
- (void)cancelAllOperationsWaitUntilFinished:(BOOL)waitUntilFinished;
// stop processing a book
- (void)cancelAllOperationsForBookIdentifier:(SCHBookIdentifier *)bookIdentifier
                           waitUntilFinished:(BOOL)waitUntilFinished;

- (void)forceAllBooksToReAcquireLicense;
- (void)checkStateForAllBooks;

// FIXME: locking queue for SCHBookCoverView, here temporarily for testings
@property dispatch_queue_t thumbnailAccessQueue;


@end
