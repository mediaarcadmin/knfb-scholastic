//
//  SCHThumbnailFactory.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHThumbnailOperation.h"
#import "SCHAsyncImageView.h"

@interface SCHThumbnailFactory : NSObject {

}

+ (NSString *) cacheDirectory;
+ (UIImage *)imageWithPath:(NSString *)path;

+ (SCHThumbnailOperation *)thumbOperationAtPath:(NSString *)thumbPath 
									   fromPath:(NSString *)path 
										   rect:(CGRect)thumbRect 
										   size:(CGSize)size 
										   flip:(BOOL)flip 
								 maintainAspect:(BOOL)aspect;

/*+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							 path:(NSString *)path 
						thumbRect:(CGRect)thumbRect 
							 flip:(BOOL)flip 
				   maintainAspect:(BOOL)aspect;
*/

+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							 path:(NSString *)path
				   maintainAspect:(BOOL)aspect;	

+ (SCHAsyncImageView *)newAsyncImageWithSize:(CGSize)size;
+ (bool) updateThumbView: (SCHAsyncImageView *) imageView withSize:(CGSize)size path:(NSString *)path;

@end
