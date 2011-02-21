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

@property (nonatomic, retain) NSOperationQueue *processingQueue;
@property (nonatomic, retain) BlioTimeOrderedCache *imageCache;

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

@end
