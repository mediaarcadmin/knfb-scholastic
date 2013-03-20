//
//  UIImage+ScholasticAdditions.m
//  Scholastic
//
//  Created by Matt Farrugia on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "UIImage+ScholasticAdditions.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (ScholasticAdditions)

+ (UIImage *)SCHCreateThumbWithSourcePath:(NSString *)sourcePath destinationPath:(NSString *)destinationPath maxDimension:(NSUInteger)maxDimension
{
    UIImage *resizedImage = nil;
    
    // debug: make sure we're not running the image resizing on the main thread
    NSAssert([NSThread currentThread] != [NSThread mainThread], @"Don't do image interpolation on the main thread!");
    
    if (sourcePath != nil && destinationPath != nil) {
        NSURL *sourceURL = [NSURL fileURLWithPath:sourcePath];
        
        CGImageSourceRef src = CGImageSourceCreateWithURL((CFURLRef)sourceURL, NULL);
        
        if (src != nil) {
            // get the main image properties without loading it into memory
            CGFloat width = 0.0f, height = 0.0f;
            CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
            if (imageProperties != NULL) {
                CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
                if (widthNum != NULL) {
                    CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
                }
                
                CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
                if (heightNum != NULL) {
                    CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
                }
                
                CFRelease(imageProperties);
            }
            
            CGFloat scale = 1.0f;
            
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
                scale = [[UIScreen mainScreen] scale];
            }
            
            CGImageRef thumbnailRef;
            
            NSInteger maxPixelSize = maxDimension * scale;
            
            if ((maxPixelSize > width) && (maxPixelSize > height)) {
                NSLog(@"WARNING: Source image is smaller than desired thumbnail. Thumbnail generation will be lossy.");
                CGFloat aspectFitScale = MIN(maxPixelSize/width, maxPixelSize/height);
                NSUInteger requiredWidth  = width * aspectFitScale;
                NSUInteger requiredHeight = height * aspectFitScale;
                
                NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)kCFBooleanFalse, kCGImageSourceShouldAllowFloat,
                                   (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                   nil];
                
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGImageRef srcImage = CGImageSourceCreateImageAtIndex(src, 0, (CFDictionaryRef) d);
                CGContextRef ctx = CGBitmapContextCreate(NULL, requiredWidth, requiredHeight, 8, 8 * 4 * requiredWidth, colorSpace, kCGImageAlphaPremultipliedLast);
                
                CGContextDrawImage(ctx, CGRectMake(0, 0, requiredWidth, requiredHeight), srcImage);
                thumbnailRef = CGBitmapContextCreateImage(ctx);
                
                CGColorSpaceRelease(colorSpace);
                CGImageRelease(srcImage);
                CGContextRelease(ctx);
            } else {
                NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)kCFBooleanFalse, kCGImageSourceShouldAllowFloat,
                                   (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                   (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                   [NSNumber numberWithInteger:maxPixelSize], kCGImageSourceThumbnailMaxPixelSize,
                                   nil];
                
                thumbnailRef = CGImageSourceCreateThumbnailAtIndex(src, 0, (CFDictionaryRef) d);
            }
            
            resizedImage = [[UIImage alloc] initWithCGImage:thumbnailRef scale:scale orientation:UIImageOrientationUp];
            
            CGImageRelease(thumbnailRef);
            CFRelease(src);
            
            if (resizedImage) {
                NSData *pngData = UIImagePNGRepresentation(resizedImage);
                [pngData writeToFile:destinationPath atomically:YES];
            }
        }
    }
    
    return [resizedImage autorelease];
}

@end
