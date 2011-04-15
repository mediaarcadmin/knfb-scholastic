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
	imageView.coverSize = size;
	
	return imageView;
}

+ (bool) updateThumbView: (SCHAsyncBookCoverImageView *) imageView withSize:(CGSize)size path:(NSString *)path {
	
	UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:path];
	imageView.image = thumbImage;
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

        float hfactor = fullImage.size.width / size.width;
        float vfactor = fullImage.size.height / size.height;
        
        float factor = MAX(hfactor, vfactor);
        
        // Divide the size by the greater of the vertical or horizontal shrinking factor
        float newThumbWidth = fullImage.size.width / factor;
        float newThumbHeight = fullImage.size.height / factor;
        
        CGRect imageRect = CGRectMake(0, 0, newThumbWidth, newThumbHeight);
        CGRect integralRect = CGRectIntegral(imageRect);
        CGRect thumbNailRect = integralRect;

       if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = [[UIScreen mainScreen] scale];
            thumbNailRect = CGRectApplyAffineTransform(thumbNailRect, CGAffineTransformMakeScale(scale, scale));
        }

        
        CGSize imageSize = thumbNailRect.size;

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, imageSize.width,  imageSize.height, 8, 4 *  imageSize.width, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
                
        CGContextDrawImage(ctx, thumbNailRect, fullImage.CGImage);
        
        CGImageRef scaledImageRef = CGBitmapContextCreateImage(ctx);
        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:scaledImageRef];
        CGImageRelease(scaledImageRef);
        
        CGContextRelease(ctx);
        
        return [scaledImage autorelease];

        
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
