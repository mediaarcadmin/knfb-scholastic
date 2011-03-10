//
//  SCHProcessingManager.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"
#import "SCHAsyncImageView.h"
#import "BlioTimeOrderedCache.h"

@interface SCHProcessingManager : NSObject {

}

+ (SCHProcessingManager *) defaultManager;
+ (NSString *) cacheDirectory;

@property (nonatomic, retain) NSOperationQueue *processingQueue;
@property (nonatomic, retain) NSOperationQueue *bookURLQueue;
@property (nonatomic, retain) BlioTimeOrderedCache *imageCache;
@property (readwrite, retain) NSMutableDictionary *currentWaitingItems;
@property (readwrite, retain) NSMutableDictionary *currentDownloadingItems;
@property (readwrite, retain) NSMutableDictionary *currentWaitingForURLItems;
@property (readwrite, retain) NSMutableDictionary *currentDownloadingCoverImages;

@property (readwrite, retain) NSMutableDictionary *currentProcessingAsyncImageViews;

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

- (void) setBookWaiting: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;
- (void) setBookDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;
- (void) setBookWaitingForURLs: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;
- (void) setCoverImageDownloading: (SCHBookInfo *) bookInfo operation: (NSOperation *) operation;

- (void) removeBookWaitingForURLs: (SCHBookInfo *) bookInfo;
- (void) removeBookFromDownload: (SCHBookInfo *) bookInfo;
- (void) removeCoverImageFromDownload: (SCHBookInfo *) bookInfo;

- (BOOL) isCurrentlyWaiting: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyDownloading: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyWaitingForURLs: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyDownloadingCoverImage: (SCHBookInfo *) bookInfo;

- (void) enterBackground;
- (void) enterForeground;

- (BOOL) hasExistingAsyncImageViewForThumbName: (NSString *) thumbName;
- (void) removeProcessingAsyncImageView: (SCHAsyncImageView *) imageView;


@end
