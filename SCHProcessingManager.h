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
@property (nonatomic, retain) BlioTimeOrderedCache *imageCache;
@property (nonatomic, retain) NSMutableDictionary *currentWaitingItems;
@property (nonatomic, retain) NSMutableDictionary *currentDownloadingItems;

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
- (void) removeBookFromDownload: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyWaiting: (SCHBookInfo *) bookInfo;
- (BOOL) isCurrentlyDownloading: (SCHBookInfo *) bookInfo;

@end
