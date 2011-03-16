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
	SCHBookInfoProcessingStateNoURLs,
	SCHBookInfoProcessingStateNoCoverImage,
	SCHBookInfoProcessingStateReadyForBookFileDownload,
	SCHBookInfoProcessingStateDownloadStarted,
	SCHBookInfoProcessingStateDownloadPaused,
	SCHBookInfoProcessingStateReadyToRead
} SCHBookInfoCurrentProcessingState;


@interface SCHProcessingManager : NSObject {

}

// the library cache directory. Used for book files and cached images.
+ (NSString *)cacheDirectory;

// shared manager instance
// FIXME: notes on duties - registers for events etc.
+ (SCHProcessingManager *) sharedProcessingManager;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

// user selection methods
- (void) userSelectedBookInfo: (SCHBookInfo *) bookInfo;

// thumbnail requests
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size;

@end
