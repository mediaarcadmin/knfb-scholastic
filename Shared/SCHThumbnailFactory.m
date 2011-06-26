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
	imageView.thumbSize = size;
	
	return imageView;
}

+ (bool) updateThumbView: (SCHAsyncBookCoverImageView *) imageView withSize:(CGSize)size path:(NSString *)path {
	
	UIImage *thumbImage = [SCHThumbnailFactory imageWithPath:path];
	imageView.image = thumbImage;
	imageView.thumbSize = size;
	
	return YES;
}

+ (CGSize) coverSizeForImageOfSize: (CGSize) fullImageSize thumbNailOfSize: (CGSize) thumbImageSize aspect: (BOOL) aspect
{
    CGRect thumbNailRect = CGRectIntegral(CGRectMake(0, 0, thumbImageSize.width, thumbImageSize.height));
    
    if (aspect) {
        
        float hfactor = fullImageSize.width / thumbImageSize.width;
        float vfactor = fullImageSize.height / thumbImageSize.height;
        
        float factor = MAX(hfactor, vfactor);
        
        // Divide the size by the greater of the vertical or horizontal shrinking factor
        float newThumbWidth = fullImageSize.width / factor;
        float newThumbHeight = fullImageSize.height / factor;
        
        CGRect imageRect = CGRectMake(0, 0, newThumbWidth, newThumbHeight);
        thumbNailRect = CGRectIntegral(imageRect);
        
    }
    
    return thumbNailRect.size;
}

+ (UIImage *)thumbnailImageOfSize:(CGSize)size 
                         forImage:(UIImage *) fullImage
				   maintainAspect:(BOOL)aspect		
{
	// debug: make sure we're not running the image resizing on the main thread
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
	
	if (!fullImage) {
		NSLog(@"No image returned!");
		return nil;
	} else {

        // get the actual scaled thumbnail size
        CGSize thumbNailSize = [self coverSizeForImageOfSize:fullImage.size thumbNailOfSize:size aspect:aspect];
        CGRect thumbNailRect = CGRectMake(0, 0, thumbNailSize.width, thumbNailSize.height);
        
        // get the correct device scale and transform for pixels
        CGFloat scale = 1.0f;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            scale = [[UIScreen mainScreen] scale];
            thumbNailRect = CGRectApplyAffineTransform(thumbNailRect, CGAffineTransformMakeScale(scale, scale));
        }

        CGSize imageSize = thumbNailRect.size;

        // image interpolation
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx = CGBitmapContextCreate(NULL, imageSize.width,  imageSize.height, 8, 4 *  imageSize.width, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGColorSpaceRelease(colorSpace);
                
        CGContextDrawImage(ctx, thumbNailRect, fullImage.CGImage);
        
        // Add 1 pixel border
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.3f);
        CGContextSetLineWidth(ctx, 2);
        CGContextStrokeRect(ctx, thumbNailRect);
        
        CGImageRef scaledImageRef = CGBitmapContextCreateImage(ctx);
        UIImage *scaledImage = [[UIImage alloc] initWithCGImage:scaledImageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(scaledImageRef);
        
        CGContextRelease(ctx);
        
        return [scaledImage autorelease];

        
	}
}



+ (UIImage *)imageWithPath:(NSString *)path {
	UIImage *image = [UIImage imageWithContentsOfFile:path];
	return image;
}

@end
