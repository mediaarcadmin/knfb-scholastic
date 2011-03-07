//
//  SCHBookInfo.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHContentMetadataItem+Extensions.h"
#import <pthread.h>
#import <CoreData/CoreData.h>

typedef enum {
	bookFileProcessingStateError = 0,
	bookFileProcessingStateNoFileDownloaded,
	bookFileProcessingStatePartiallyDownloaded,
	bookFileProcessingStateFullyDownloaded
} BookFileProcessingState;



@interface SCHBookInfo : NSObject {

}

// FIXME: used in testing - disable for release builds
@property (nonatomic) pthread_t currentThread;

//@property (nonatomic, retain) NSManagedObjectID *metadataItemID;
@property (readwrite, retain) NSString *bookIdentifier;
@property (readonly) SCHContentMetadataItem *contentMetadata;

- (id) initWithContentMetadataItem: (SCHContentMetadataItem *) metadataItem;
- (NSString *) xpsPath;
- (BookFileProcessingState) processingState;
- (BOOL) processedCovers;
- (BOOL) isCurrentlyDownloading;
- (BOOL) isWaitingForDownload;
- (float) currentDownloadedPercentage;

@end
