//
//  SCHOldProcessingManager.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"
#import "SCHAsyncImageView.h"
#import "BlioTimeOrderedCache.h"

@interface SCHOldProcessingManager : NSObject {

}

+ (SCHOldProcessingManager *) defaultManager;
+ (NSString *) cacheDirectory;

@property (nonatomic, retain) NSOperationQueue *processingQueue;
@property (nonatomic, retain) NSOperationQueue *downloadQueue;
@property (nonatomic, retain) NSOperationQueue *bookURLQueue;
@property (nonatomic, retain) BlioTimeOrderedCache *imageCache;
@property (readwrite, retain) NSMutableDictionary *currentWaitingBookFileItems;
@property (readwrite, retain) NSMutableDictionary *currentDownloadingBookFileItems;

@property (readwrite, retain) NSMutableDictionary *currentWaitingForURLItems;


@property (readwrite, retain) NSMutableDictionary *currentWaitingCoverImages;
@property (readwrite, retain) NSMutableDictionary *currentDownloadingCoverImages;

//@property (readwrite, retain) NSMutableDictionary *currentProcessingAsyncImageViews;

//- (void) enqueueBookInfoItems: (NSArray *) bookInfoItems;

- (BOOL) updateAsyncThumbView: (SCHAsyncImageView *) imageView 
			   withBook: (SCHBookInfo *) bookInfo 
		imageOfInterest: (NSString *) imageOfInterest 
				   size: (CGSize) size 
				   rect:(CGRect) thumbRect 
		 maintainAspect:(BOOL)aspect 
		 usePlaceHolder:(BOOL) placeholder;

- (bool) updateThumbView: (SCHAsyncImageView *) imageView 
				withBook: (SCHBookInfo *) bookInfo 
					size:(CGSize)size 
					rect:(CGRect)thumbRect 
					flip:(BOOL)flip 
		  maintainAspect:(BOOL)aspect 
		  usePlaceHolder:(BOOL)placeholder;

- (void) downloadBookFile: (SCHBookInfo *) bookInfo;

- (void) setBookFileWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;
- (void) setBookFileDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;

- (void) setCoverImageWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;
- (void) setCoverImageDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;

- (BOOL) setBookWaitingForURLs: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;


- (void) removeBookFromDownload: (SCHBookInfo *) bookInfo;
- (void) removeCoverImageFromDownload: (SCHBookInfo *) bookInfo;
- (void) removeBookWaitingForURLs: (SCHBookInfo *) bookInfo;

- (BOOL) isCurrentlyWaitingForBookFile: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyWaitingForCoverImage: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyDownloading: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyWaitingForURLs: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyDownloadingCoverImage: (SCHBookInfo *) bookInfo;

- (void) enterBackground;
- (void) enterForeground;

//- (BOOL) hasExistingAsyncImageViewForThumbName: (NSString *) thumbName;
//- (void) removeProcessingAsyncImageView: (SCHAsyncImageView *) imageView;


@end
