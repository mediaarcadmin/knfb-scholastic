//
//  SCHProcessingManager.h
//  Scholastic
//
//  Created by Gordon Christie on 14/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHBookInfo;
@class SCHAsyncBookCoverImageView;

typedef enum {
	SCHBookInfoProcessingStateError = 0,
	SCHBookInfoProcessingStateBookVersionNotSupported,
	SCHBookInfoProcessingStateNoURLs,
	SCHBookInfoProcessingStateNoCoverImage,
	SCHBookInfoProcessingStateReadyForBookFileDownload,
	SCHBookInfoProcessingStateDownloadStarted,
	SCHBookInfoProcessingStateDownloadPaused,
	SCHBookInfoProcessingStateReadyForRightsParsing,
	SCHBookInfoProcessingStateReadyToRead
} SCHBookInfoCurrentProcessingState;


@interface SCHProcessingManager : NSObject {

}

// shared manager instance
// FIXME: notes on duties - registers for events etc.
+ (SCHProcessingManager *) sharedProcessingManager;

// user selection method
- (void) userSelectedBookInfo: (SCHBookInfo *) bookInfo;

// thumbnail requests
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size;

@end
