//
//  SCHThumbnailFactory.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailFactory.h"
//#import "BlioTimeOrderedCache.h"

@interface SCHThumbnailFactory ()

@end

#pragma mark -
@implementation SCHThumbnailFactory

+ (SCHAsyncBookCoverImageView *)newAsyncImageWithSize:(CGSize)size {
	CGRect viewBounds = CGRectMake(0, 0, size.width, size.height);
	
	SCHAsyncBookCoverImageView *imageView = [[SCHAsyncBookCoverImageView alloc] initWithFrame:viewBounds];
	imageView.contentMode = UIViewContentModeScaleToFill;
	imageView.clipsToBounds = YES;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.backgroundColor = [UIColor clearColor];
	imageView.tag = 666;
	imageView.coverSize = size;
	
	return imageView;
}

+ (bool) updateThumbView: (SCHAsyncBookCoverImageView *) imageView withSize:(CGSize)size path:(NSString *)path {
	
	UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:path];
	imageView.contentMode = UIViewContentModeScaleToFill;
	imageView.image = thumbImage;
	imageView.clipsToBounds = YES;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.backgroundColor = [UIColor clearColor];
	imageView.coverSize = size;
	
	return YES;
}

+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							 path:(NSString *)path
				   maintainAspect:(BOOL)aspect		
{
	// debug: make sure we're not running the image resizing on the main thread
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
	
	UIImage *fullImage = [SCHThumbnailFactory imageWithPath:path];
	
	if (!fullImage) {
		NSLog(@"No image returned!");
		return nil;
	} else {
		
		if (aspect) {
			
			CGFloat xRatio = size.width / fullImage.size.width;
			CGFloat yRatio = size.height / fullImage.size.height;
	
			NSLog(@"xratio: %f yratio: %f", xRatio, yRatio);
		}
		
		UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
		[fullImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return newImage;
	}
}



+ (UIImage *)imageWithPath:(NSString *)path {
	UIImage *image = nil;
	
//	NSData *imageData = [[[SCHProcessingManager defaultManager] imageCache] objectForKey:path];
	
//	if (!imageData) {
		
		NSData *imageData = [NSData dataWithContentsOfMappedFile:path];
		
//		if (imageData) {
			// only cache small images
//			if ([imageData length] < (1024 * 512)) {
//				[[[SCHProcessingManager defaultManager] imageCache] setObject:imageData forKey:path cost:[imageData length]];
//			}
//		}
//	}
		
	if (imageData) {
		image = [UIImage imageWithData:imageData];
	}
	
	return image;
}

/*+ (SCHThumbnailOperation *)thumbOperationForBook: (SCHBookInfo *) bookInfo size:(CGSize)size flip:(BOOL)flip maintainAspect:(BOOL)aspect {
	SCHThumbnailOperation *aOperation = [[SCHThumbnailOperation alloc] init];
	aOperation.bookInfo = bookInfo;
	aOperation.size = size;
	aOperation.flip = flip;
	aOperation.aspect = aspect;
	
	return [aOperation autorelease];
}*/
@end
