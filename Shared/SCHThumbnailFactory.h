//
//  SCHThumbnailFactory.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHThumbnailOperation.h"
#import "SCHAsyncBookCoverImageView.h"

@interface SCHThumbnailFactory : NSObject {

}

+ (UIImage *)imageWithPath:(NSString *)path;

//+ (SCHThumbnailOperation *)thumbOperationAtPath:(NSString *)thumbPath fromPath:(NSString *)path size:(CGSize)size flip:(BOOL)flip maintainAspect:(BOOL)aspect;

/*+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							 path:(NSString *)path
				   maintainAspect:(BOOL)aspect;	
*/

+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
                         forImage:(UIImage *) fullImage
				   maintainAspect:(BOOL)aspect;		

+ (SCHAsyncBookCoverImageView *)newAsyncImageWithSize:(CGSize)size;
+ (bool) updateThumbView: (SCHAsyncBookCoverImageView *) imageView withSize:(CGSize)size path:(NSString *)path;
+ (CGSize) coverSizeForImageOfSize: (CGSize) fullImageSize thumbNailOfSize: (CGSize) thumbImageSize aspect: (BOOL) aspect;

@end
