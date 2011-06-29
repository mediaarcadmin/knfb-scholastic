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
@class NSManagedObjectContext;

typedef enum {
	SCHBookProcessingStateError = -2,
	SCHBookProcessingStateBookVersionNotSupported,
	SCHBookProcessingStateNoURLs,
	SCHBookProcessingStateNoCoverImage,
	SCHBookProcessingStateReadyForBookFileDownload,
	SCHBookProcessingStateDownloadStarted,
	SCHBookProcessingStateDownloadPaused,
	SCHBookProcessingStateReadyForLicenseAcquisition,
	SCHBookProcessingStateReadyForRightsParsing,
	SCHBookProcessingStateReadyForAudioInfoParsing,
	SCHBookProcessingStateReadyForTextFlowPreParse,
    SCHBookProcessingStateReadyForSmartZoomPreParse,
	SCHBookProcessingStateReadyForPagination,
	SCHBookProcessingStateReadyToRead
} SCHBookCurrentProcessingState;

static NSString * const kSCHProcessingManagerConnectionIdle = @"SCHProcessingManagerConnectionIdle";
static NSString * const kSCHProcessingManagerConnectionBusy = @"SCHProcessingManagerConnectionBusy";

@interface SCHProcessingManager : NSObject {}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// shared manager instance
// FIXME: notes on duties - registers for events etc.
+ (SCHProcessingManager *) sharedProcessingManager;

// user selection method
- (void) userSelectedBookWithISBN: (NSString *) isbn;

// thumbnail requests
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size book:(SCHAppBook *)book;

// methods for processing
- (BOOL) ISBNisProcessing: (NSString *) isbn;
- (void) setProcessing: (BOOL) processing forISBN: (NSString *) isbn;

// stop all the processing
- (void)cancelAllOperations;

@end
