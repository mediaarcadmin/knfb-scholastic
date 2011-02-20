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

@interface SCHProcessingManager : NSObject {

}

+ (SCHProcessingManager *) defaultManager;

@property (nonatomic, retain) NSOperationQueue *processingQueue;

//- (void) enqueueBookInfoItems: (NSArray *) bookInfoItems;

- (UIImageView *) thumbImageForBook: (SCHBookInfo *) bookInfo frame: (CGRect) frame rect: (CGRect) thumbRect flip: (BOOL) flip maintainAspect: (BOOL) aspect usePlaceholder: (BOOL) placeholder;
- (BOOL) asyncThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size: (CGSize) size srcPath:(NSString *) path dstPath:(NSString *)thumbPath rect:(CGRect) thumbRect maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL) placeholder;
- (bool) updateThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size:(CGSize)size rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL)placeholder;
//+ (bool) updateThumbView: (SCHAsyncImageView *) imageView withSize:(CGSize)size path:(NSString *)path rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL)placeholder;
//+ (bool) updateThumbView: (SCHAsyncImageView *) imageView withBook: (SCHBookInfo *) bookInfo size:(CGSize)size path:(NSString *)path rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect usePlaceHolder:(BOOL)placeholder;

@end
