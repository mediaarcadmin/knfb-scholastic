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

static const NSInteger bookInfoProcessingStateNotProcessed = 0;
static const NSInteger bookInfoProcessingStateProcessed = 1;


@interface SCHBookInfo : NSObject {

}

// FIXME: used in testing - disable for release builds
@property (nonatomic) pthread_t currentThread;

@property (nonatomic, retain) NSManagedObjectID *metadataItemID;
@property (readonly) SCHContentMetadataItem *contentMetadata;

- (id) initWithContentMetadataItem: (SCHContentMetadataItem *) metadataItem;
- (NSString *) xpsPath;
- (UIImageView *) thumbImageForBook;


@end
