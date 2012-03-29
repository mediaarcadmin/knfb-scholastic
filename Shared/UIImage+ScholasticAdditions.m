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
        
        NSInteger maxPixelSize = maxDimension * scale;
        
        NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kCFBooleanFalse, kCGImageSourceShouldAllowFloat,
                           (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                           (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                           [NSNumber numberWithInteger:maxPixelSize], kCGImageSourceThumbnailMaxPixelSize,
                           nil];
        
        CGImageRef thumbnailRef = CGImageSourceCreateThumbnailAtIndex(src, 0, (CFDictionaryRef) d);
        
        resizedImage = [[UIImage alloc] initWithCGImage:thumbnailRef scale:scale orientation:UIImageOrientationUp];
        
        CGImageRelease(thumbnailRef);
        CFRelease(src);
        
        if (resizedImage) {
            NSData *pngData = UIImagePNGRepresentation(resizedImage);
            [pngData writeToFile:destinationPath atomically:YES];
        }
    }
    
    return [resizedImage autorelease];
}

@end
