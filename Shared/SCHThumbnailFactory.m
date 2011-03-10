//
//  SCHThumbnailFactory.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailFactory.h"
#import "SCHProcessingManager.h"
#import "BlioTimeOrderedCache.h"

@interface SCHThumbnailFactory ()

/*+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							image:(UIImage *)fullImage
						thumbRect:(CGRect)thumbRect 
							 flip:(BOOL)flip 
				   maintainAspect:(BOOL)aspect;
*/
@end

#pragma mark -
@implementation SCHThumbnailFactory

+ (SCHAsyncImageView *)newAsyncImageWithSize:(CGSize)size {
	CGRect viewBounds = CGRectMake(0, 0, size.width, size.height);
	
	SCHAsyncImageView *imageView = [[SCHAsyncImageView alloc] initWithFrame:viewBounds];
	imageView.contentMode = UIViewContentModeScaleToFill;
	imageView.clipsToBounds = YES;
	//imageView.image = [UIImage imageNamed:@"missingImage.png"];
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.backgroundColor = [UIColor clearColor];
	imageView.tag = 666;
	
	return imageView;
}

+ (bool) updateThumbView: (SCHAsyncImageView *) imageView withSize:(CGSize)size path:(NSString *)path {
	
	UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:path];
	imageView.contentMode = UIViewContentModeScaleToFill;
	imageView.image = thumbImage;
	imageView.clipsToBounds = YES;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	imageView.backgroundColor = [UIColor clearColor];
	
	return YES;
}

/*
+ (UIImage *)thumbnailImageOfSize:(CGSize)size path:(NSString *)path thumbRect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect {
	UIImage *fullImage = [SCHThumbnailFactory imageWithPath:path];
	
	if (!fullImage) {
		return nil;
	} else {
		return [self thumbnailImageOfSize:size image:fullImage thumbRect:thumbRect flip:flip maintainAspect:aspect];
	}
}


+ (UIImage *)thumbnailImageOfSize:(CGSize)size image:(UIImage *)fullImage thumbRect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect {
	
	if (!fullImage) {
		return nil;
	}
	
	if (flip) {
		thumbRect.origin.y = fullImage.size.height - thumbRect.origin.y - thumbRect.size.height;
	}
	
	CGFloat xRatio = size.width / thumbRect.size.width;
	CGFloat yRatio = size.height / thumbRect.size.height;
	
	CGRect fittedRect = thumbRect;
	
	if (aspect) {
		
		if (xRatio < yRatio) {
			fittedRect.size.height = thumbRect.size.width * (size.height / size.width);
		} else {
			fittedRect.size.width = thumbRect.size.height * (size.width / size.height);
		}
		
	}
	
	
	if (fittedRect.size.width > fullImage.size.width) {
		CGFloat ratio = fullImage.size.width / fittedRect.size.width;
		fittedRect.size.width = fullImage.size.width;
		fittedRect.size.height *= ratio;
	} else {
		fittedRect.origin.x += (thumbRect.size.width - fittedRect.size.width) / 2.0f;
		
	}
	
	if (fittedRect.size.height > fullImage.size.height) {
		CGFloat ratio = fullImage.size.height / fittedRect.size.height;
		fittedRect.size.height = fullImage.size.height;
		fittedRect.size.width *= ratio;
	} else {
		fittedRect.origin.y += (thumbRect.size.height - fittedRect.size.height) / 2.0f;
	}
	
	
	if (CGRectGetMinX(fittedRect) < 0) {
		CGFloat diff = 0 - CGRectGetMinX(fittedRect);
		fittedRect.origin.x += diff;
	}
	
	if (CGRectGetMaxX(fittedRect) > fullImage.size.width) {
		CGFloat diff = fullImage.size.width - CGRectGetMaxX(fittedRect);
		fittedRect.origin.x += diff;
	}
	
	
	if (CGRectGetMinY(fittedRect) < 0) {
		CGFloat diff = 0 - CGRectGetMinY(fittedRect);
		fittedRect.origin.y += diff;
	}
	
	if (CGRectGetMaxY(fittedRect) > fullImage.size.height) {
		CGFloat diff = fullImage.size.height - CGRectGetMaxY(fittedRect);
		fittedRect.origin.y += diff;
	}
	
	CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		CGFloat scale = [[UIScreen mainScreen] scale];
		imageRect = CGRectApplyAffineTransform(imageRect, CGAffineTransformMakeScale(scale, scale));
	}
	
	// convert to closest int values for imagerect
	CGRect thumbNailRect = CGRectIntegral(imageRect);
	CGSize imageSize = thumbNailRect.size;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 4 * imageSize.width, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	
	CGImageRef thumbRectImageRef = CGImageCreateWithImageInRect(fullImage.CGImage, fittedRect);
	
	CGContextDrawImage(ctx, thumbNailRect, thumbRectImageRef);
	CGImageRelease(thumbRectImageRef);
	
	CGImageRef scaledImageRef = CGBitmapContextCreateImage(ctx);
	UIImage *scaledImage = [[UIImage alloc] initWithCGImage:scaledImageRef];
	CGImageRelease(scaledImageRef);
	
	CGContextRelease(ctx);
	
	return [scaledImage autorelease];
}
 */

+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
							 path:(NSString *)path
				   maintainAspect:(BOOL)aspect		
{
	// debug: make sure we're not running the image resizing on the main thread
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
	
	NSLog(@"++++++++++++++++++++++++++ file exists at path? %@", ([[NSFileManager defaultManager] fileExistsAtPath:path])?@"Yes":@"No!");
	
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

+ (SCHThumbnailOperation *)thumbOperationAtPath:(NSString *)thumbPath fromPath:(NSString *)path rect:(CGRect)thumbRect size:(CGSize)size flip:(BOOL)flip maintainAspect:(BOOL)aspect {
	SCHThumbnailOperation *aOperation = [[SCHThumbnailOperation alloc] init];
	aOperation.path = path;
	aOperation.thumbPath = thumbPath;
	aOperation.thumbRect = thumbRect;
	aOperation.size = size;
	aOperation.flip = flip;
	aOperation.aspect = aspect;
	
	return [aOperation autorelease];
}
@end
