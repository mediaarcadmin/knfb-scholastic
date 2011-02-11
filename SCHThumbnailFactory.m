//
//  SCHImageCache.m
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThumbnailFactory.h"

#pragma mark SCHImageCache Class Extension

@interface SCHThumbnailFactory ()

@property (nonatomic, retain) NSOperationQueue *queue;

@end

#pragma mark -
@implementation SCHThumbnailFactory

@synthesize queue;

static SCHThumbnailFactory *sharedImageCache = nil;

+ (NSString *)cacheDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (UIImageView *)thumbViewWithFrame:(CGRect)frame path:(NSString *)path rect:(CGRect)thumbRect flip:(BOOL)flip maintainAspect:(BOOL)aspect {
	NSString *cacheDir  = [SCHThumbnailFactory cacheDirectory];
	NSString *thumbPath = [NSString stringWithFormat:@"%@_%d_%d_%d_%d", [path lastPathComponent], (int)floor(CGRectGetMinX(thumbRect)), (int)floor(CGRectGetMinY(thumbRect)), (int)floor(thumbRect.size.width), (int)floor(thumbRect.size.height)];
	
	NSString *cachePath = [cacheDir stringByAppendingPathComponent:thumbPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
		UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:cachePath];
		if (thumbImage) {
			UIImageView *aImageView = [[UIImageView alloc] initWithImage:thumbImage];
			aImageView.frame = frame;
			return [aImageView autorelease];
		}
	} else {
		UIImage *missingImage = [UIImage imageNamed:@"missingImage.png"];
		CGSize missingImageSize = missingImage.size;

		// check for scale, for retina display
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			CGFloat scale = [[UIScreen mainScreen] scale];
			missingImageSize = CGSizeMake(missingImageSize.width * scale, missingImageSize.height * scale);
		}
		
		UIImage *placeholderImage = [SCHThumbnailFactory thumbnailImageOfSize:frame.size 
																  image:missingImage 
															  thumbRect:CGRectMake(0, 0, missingImageSize.width, missingImageSize.height) 
																   flip:NO 
														 maintainAspect:aspect];
		
		SCHAsyncImageView *aAsyncImageView = [[SCHAsyncImageView alloc] initWithImage:placeholderImage];
		aAsyncImageView.frame = frame;
		aAsyncImageView.imageOfInterest = thumbPath;
		aAsyncImageView.contentMode = UIViewContentModeScaleToFill;
		
		SCHThumbnailOperation *aOperation = [SCHThumbnailFactory thumbOperationAtPath:thumbPath 
																		   fromPath:path 
																			   rect:thumbRect 
																			   size:frame.size 
																			   flip:flip 
																	 maintainAspect:aspect];
		
		SCHThumbnailFactory *defaultCache = [SCHThumbnailFactory defaultCache];
		[[defaultCache queue] addOperation:aOperation];
		
		aAsyncImageView.operation = aOperation;
		
		return [aAsyncImageView autorelease];
	}
	
	return nil;
}


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
	
	//CGFloat aspectScale = MIN(size.width / thumbRect.size.width, size.height / thumbRect.size.height);
	
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
	
	CGRect integralRect = CGRectIntegral(imageRect);
	CGRect thumbNailRect = integralRect;
	CGSize imageSize = integralRect.size;
	
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

+ (UIImage *)imageWithPath:(NSString *)path {
	UIImage *image = nil;
	
	NSData *imageData = [NSData dataWithContentsOfMappedFile:path];
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



#pragma mark -
#pragma mark Singleton methods

// Singleton methods are copied directly from http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html%23//apple_ref/doc/uid/TP40002974-CH4-SW32
// These denote a singleton that cannot be separately allocated alongside the sharedFactory

+(SCHThumbnailFactory*) defaultCache
{
    if (sharedImageCache == nil) {
        sharedImageCache = [[super allocWithZone:NULL] init];
    }
    return sharedImageCache;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [[self defaultCache] retain];
}

-(id) copyWithZone:(NSZone *)zone 
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount 
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
