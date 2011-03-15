//
//  SCHBookInfo.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <CoreData/CoreData.h>
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHProcessingManager.h"


@interface SCHBookInfo : NSObject {

}

// the initialiser for SCHBookInfo - only one object per book is created
+ (id) bookInfoWithContentMetadataItem: (SCHContentMetadataItem *) metadataItem;

// SCHBookInfo objects use the book identifier (ISBN number) as a unique ID
@property (readwrite, retain) NSString *bookIdentifier;

// core data objects - content metadata comes from the web service,
// local metadata is state held locally for books
@property (readonly) SCHContentMetadataItem *contentMetadata;
//@property (readonly) SCHLocalMetadataItem *localMetadata;

// the cover and book file URLs
@property (readwrite, retain) NSString *coverURL;
@property (readwrite, retain) NSString *bookFileURL;

// is this book currently being processed?
@property (getter=isProcessing) BOOL processing;
// the current processing state of the book
@property (readwrite) SCHBookInfoCurrentProcessingState processingState;

// the path to the XPS file within the system - by default, in the cache directory
- (NSString *) xpsPath;
- (NSString *) coverImagePath;
- (NSString *) thumbPathForSize: (CGSize) size;

// book file current percentage downloaded
- (float) currentDownloadedPercentage;

@end
