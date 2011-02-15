//
//  SCHProcessingManager.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"

@interface SCHProcessingManager : NSObject {

	
	
}

@property (nonatomic, retain) NSOperationQueue *processingQueue;

- (void) enqueueBookInfoItems: (NSArray *) bookInfoItems;
- (void) enqueueBookInfoItem: (SCHBookInfo *) bookInfo;

@end
