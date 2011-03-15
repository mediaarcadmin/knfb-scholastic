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
+ (SCHProcessingManager *) sharedProcessingManager;

// Start and stop methods - called by the AppDelegate.
// Tells the processing manager to start/stop listening for web service events
- (void) start;
- (void) stop;

// background processing - called by the app delegate when the app
// is put into or opened from the background
- (void) enterBackground;
- (void) enterForeground;

// user selection methods
- (void) userSelectedBookInfo: (SCHBookInfo *) bookInfo;
- (BOOL) shouldOpenBook: (SCHBookInfo *) bookInfo;

// thumbnail requests
- (BOOL) requestThumbImageForBookCover:(SCHAsyncBookCoverImageView *)bookCover size:(CGSize)size;
- (void) checkAndDispatchThumbsForBook: (SCHBookInfo *) bookInfo;

@end
