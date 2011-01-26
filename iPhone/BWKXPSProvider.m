//
//  BWKXPSProvider.m
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import "BWKXPSProvider.h"
#import "BlioTimeOrderedCache.h"
#import "zlib.h"


@interface BlioXPSBitmapReleaseCallback : NSObject {
    void *data;
}

@property (nonatomic, assign) void *data;

@end

@interface BWKXPSProvider()

@property (nonatomic, retain) NSString *tempDirectory;
@property (nonatomic, assign) RasterImageInfo *imageInfo;
@property (nonatomic, retain) NSMutableDictionary *xpsData;
@property (nonatomic, retain) BlioTimeOrderedCache *componentCache;
@property (nonatomic, retain) NSMutableDictionary *pageCropsCache;
@property (nonatomic, retain) NSMutableDictionary *viewTransformsCache;
@property (nonatomic, assign, readonly) BOOL bookIsEncrypted;
@property (nonatomic, retain) NSString *xpsPagesDirectory;
@property (nonatomic, retain) NSMutableArray *uriMap;

- (void)deleteTemporaryDirectoryAtPath:(NSString *)path;
- (NSData *)decompressWithRawDeflate:(NSData *)data;
- (NSData *)decompressWithGZipCompression:(NSData *)data;
- (NSData *)decompress:(NSData *)data windowBits:(NSInteger)windowBits;

- (NSData *)dataForComponentAtPath:(NSString *)path;
- (NSData *)dataFromXPSAtPath:(NSString *)path;

- (NSData *)replaceMappedResources:(NSData *)data;
- (UIImage *)missingCoverImageOfSize:(CGSize)size;


@end


@implementation BWKXPSProvider

@synthesize imageInfo, tempDirectory, xpsData, componentCache, xpsPath, pageCount, pageCropsCache, viewTransformsCache, xpsPagesDirectory, uriMap, title;

void XPSPageCompleteCallback(void *userdata, RasterImageInfo *data) {
	BWKXPSProvider *provider = (BWKXPSProvider *)userdata;	
	provider.imageInfo = data;
}

- (CGRect)cropRectForPage:(NSInteger)page {
    [renderingLock lock];
	memset(&properties,0,sizeof(properties));
	XPS_GetFixedPageProperties(xpsHandle, 0, page - 1, &properties);
	CGRect cropRect = CGRectMake(properties.contentBox.x, properties.contentBox.y, properties.contentBox.width, properties.contentBox.height);
    [renderingLock unlock];
    
    return cropRect;
}

- (void) dealloc
{
	[self deleteTemporaryDirectoryAtPath:self.tempDirectory];
	[super dealloc];
}

- (id) initWithPath: (NSString *) path
{
	if ((self = [super init])) {
		
        renderingLock = [[NSLock alloc] init];
        contentsLock = [[NSLock alloc] init];
        inflateLock = [[NSLock alloc] init];
        
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef UUIDString = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        self.tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:(NSString *)UUIDString];
        //NSLog(@"temp string is %@ for book with ID %@", (NSString *)UUIDString, self.bookID);
        
        NSError *error;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.tempDirectory]) {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.tempDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"Unable to create temp XPS directory at path %@ with error %@ : %@", self.tempDirectory, error, [error userInfo]);
                CFRelease(UUIDString);
                return nil;
            }
        }
        
        XPS_Start();
        self.xpsPath = path;
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.xpsPath]) {
            NSLog(@"Error creating xpsProvider. File does not exist at path: %@", self.xpsPath);
            CFRelease(UUIDString);
            return nil;
        }
        
        xpsHandle = XPS_Open([self.xpsPath UTF8String], [self.tempDirectory UTF8String]);
        
/*        decryptionAvailable = NO;
        
        if ([self bookIsEncrypted]) {
            XPS_URI_PLUGIN_INFO	upi = {
                XPS_URI_SOURCE_PLUGIN,
                sizeof(XPS_URI_PLUGIN_INFO),
                "",
                self,
                BlioXPSProviderDRMOpen,
                NULL,
                BlioXPSProviderDRMRewind,
                BlioXPSProviderDRMSkip,
                BlioXPSProviderDRMRead,
                BlioXPSProviderDRMSize,
                BlioXPSProviderDRMClose
            };
            
            strncpy(upi.guid, [(NSString *)UUIDString UTF8String], [(NSString *)UUIDString length]);
			
            XPS_RegisterDrmHandler(xpsHandle, &upi);
            //NSLog(@"Registered drm handler for book %@ with handle %p with userdata %p", [self.book valueForKey:@"title"], xpsHandle, self);
        }*/
        CFRelease(UUIDString);
        
        XPS_SetAntiAliasMode(xpsHandle, XPS_ANTIALIAS_ON);
        pageCount = XPS_GetNumberPages(xpsHandle, 0);
        
        self.xpsData = [NSMutableDictionary dictionary];
        
        BlioTimeOrderedCache *aCache = [[BlioTimeOrderedCache alloc] init];
        aCache.countLimit = 30; // Arbitrary 30 object limit
        aCache.totalCostLimit = 1024*1024; // Arbitrary 1MB limit. This may need wteaked or set on a per-device basis
        self.componentCache = aCache;
        [aCache release];
		
		firstPageCrop = [self cropRectForPage:1];

		//drmSessionManager = nil;
    }
    return self;
	
	
}

- (void)deleteTemporaryDirectoryAtPath:(NSString *)path {
    // Should have been deleted by XPS cleanup but remove if not
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    NSFileManager *threadSafeManager = [[NSFileManager alloc] init];
    if ([threadSafeManager fileExistsAtPath:path]) {
        //NSLog(@"Removing temp XPS directory at path %@", path);
		
        if (![threadSafeManager removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing temp XPS directory at path %@ with error %@ : %@", path, error, [error userInfo]);
        }
    }
    [threadSafeManager release];
    [pool drain];
}

- (NSData *)rawDataForComponentAtPath:(NSString *)path {
    NSData *rawData = nil;
    
    XPS_FILE_PACKAGE_INFO packageInfo;
    [contentsLock lock];

    int ret = XPS_GetComponentInfo(xpsHandle, (char *)[path UTF8String], &packageInfo);
    [contentsLock unlock];
    if (!ret) {
        NSLog(@"Nothing returned from getcomponentinfo. Error opening component at path %@", path);
        return nil;
    } else {
        NSData *packageData = [NSMutableData dataWithBytes:packageInfo.pComponentData length:packageInfo.length];
        //NSLog(@"Raw data length %d (%d) with compression %d", [rawData length], packageInfo.length, packageInfo.compression_type);
        if (packageInfo.compression_type == 8) {
            rawData = [self decompressWithRawDeflate:packageData];
            if ([rawData length] == 0) {
                NSLog(@"Error decompressing component at path %@", path);
            }
        } else {
            rawData = packageData;
        }
    }
    
    if ([rawData length] == 0) {
        NSLog(@"No data. Error opening component at path %@", path);
        return nil;
    }
    
    return rawData;
}


- (CGContextRef)RGBABitmapContextForPage:(NSUInteger)page
                                fromRect:(CGRect)rect
                                 minSize:(CGSize)size 
                              getContext:(id *)context {
	// get the page crop
	CGRect pageCropRect = [self cropRectForPage:page];
    
	// work out the affine transform to get the rendering output you want
    OutputFormat format;
    memset(&format,0,sizeof(format));
    
    CGFloat pageSizeScaleWidth  = size.width / pageCropRect.size.width;
    CGFloat pageSizeScaleHeight = size.height / pageCropRect.size.height;
    
    CGFloat pageZoomScaleWidth  = size.width / CGRectGetWidth(rect);
    CGFloat pageZoomScaleHeight = size.height / CGRectGetHeight(rect);
    
	// this is the affine transform
    XPS_ctm render_ctm = { pageZoomScaleWidth, 0, 0, pageZoomScaleHeight, 
		-rect.origin.x * pageZoomScaleWidth, -rect.origin.y * pageZoomScaleHeight};
    format.xResolution = 96;			
    format.yResolution = 96;	
    format.colorDepth = 8;
    format.colorSpace = XPS_COLORSPACE_RGBA;
    format.pagesizescale = 1;	
    format.pagesizescalewidth = pageSizeScaleWidth;		
    format.pagesizescaleheight = pageSizeScaleHeight;
    format.ctm = &render_ctm;				
    format.formatType = OutputFormat_RAW;
    imageInfo = NULL;
    
	
    [renderingLock lock];
	//call XPS_RegisterPageCompleteCallback to register a function to invoke when the page 
	// rendering is complete - this callback will be passed a block of memory containing the bitmap
	XPS_RegisterPageCompleteCallback(xpsHandle, XPSPageCompleteCallback);
	
	// Call XPS_SetUserData to pass in the current object as a parameter to that 
	// callback (so we can set the bitmap data as a property)
    XPS_SetUserData(xpsHandle, self);
	
	// Call XPS_Convert to actually do the work.
	// By the time this call returns, the callback will have been called and the 
	// object will now have the bitmap data sitting in imageInfo (if it has worked)
    XPS_Convert(xpsHandle, NULL, 0, page - 1, 1, &format);
    
	// Now a bitmap context is wrapped around that existing bitmap (to save us doing a copy)
    CGContextRef bitmapContext = nil;
    
    if (imageInfo) {
        size_t width  = imageInfo->widthInPixels;
        size_t height = imageInfo->height;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
        bitmapContext = CGBitmapContextCreate(imageInfo->pBits, width, height, 8, imageInfo->rowStride, 
											  colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
		
		// the context is set to be an object of type BlioXPSBitmapReleaseCallback 
		// whose only purpose is to release the memory properly when it is deallocated
        BlioXPSBitmapReleaseCallback *releaseCallback = [[BlioXPSBitmapReleaseCallback alloc] init];
        releaseCallback.data = imageInfo->pBits;
        
        *context = [releaseCallback autorelease];
		
        CGColorSpaceRelease(colorSpace);
    }
    [renderingLock unlock];
    
	// Return the context (cast to an id so it can be autoreleased). 
	// So that means you need to use or retain the result before the end of the run loop
	return (CGContextRef)[(id)bitmapContext autorelease];
}

// GMC

- (void)createLayoutCacheForPage:(NSInteger)page {
    // N.B. please ensure this is only called with a [layoutCacheLock lock] acquired
    if (nil == self.pageCropsCache) {
        self.pageCropsCache = [NSMutableDictionary dictionaryWithCapacity:pageCount];
    }
    if (nil == self.viewTransformsCache) {
        self.viewTransformsCache = [NSMutableDictionary dictionaryWithCapacity:pageCount];
    }
    
    CGRect cropRect = [self cropRectForPage:page];
    if (!CGRectEqualToRect(cropRect, CGRectZero)) {
        [self.pageCropsCache setObject:[NSValue valueWithCGRect:cropRect] forKey:[NSNumber numberWithInt:page]];
    }
}

- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate {
	
	// if an estimate will suffice, just use the first page crop
    if (estimate) {
        return firstPageCrop;
    }
    
   // [layoutCacheLock lock];
    
	// caches the crop rectangle so we don't have to keep going back to XPS
	// for the myriad of times we need the value
    NSValue *pageCropValue = [self.pageCropsCache objectForKey:[NSNumber numberWithInt:page]];
    
    if (nil == pageCropValue) {
        [self createLayoutCacheForPage:page];
        pageCropValue = [self.pageCropsCache objectForKey:[NSNumber numberWithInt:page]];
    }
    
    //[layoutCacheLock unlock];
    
    if (pageCropValue) {
        CGRect cropRect = [pageCropValue CGRectValue];
        return cropRect;
    }
    
    return CGRectZero;
}

#pragma mark -
#pragma mark BlioLayoutDataSource

- (NSInteger)pageCount {
    return pageCount;
}

- (CGRect)mediaRectForPage:(NSInteger)page {
    [renderingLock lock];
	memset(&properties,0,sizeof(properties));
	XPS_GetFixedPageProperties(xpsHandle, 0, page - 1, &properties);
	CGRect mediaRect = CGRectMake(0, 0, properties.width, properties.height);
    [renderingLock unlock];
    
    return mediaRect;
}


- (UIImage *)coverThumbForList {
	
	CGFloat scaleFactor = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scaleFactor = [[UIScreen mainScreen] scale];
    }
	
	CGFloat targetThumbWidth = 0;
	CGFloat targetThumbHeight = 0;
	NSInteger scaledTargetThumbWidth = 0;
	NSInteger scaledTargetThumbHeight = 0;
	
	targetThumbWidth = kBlioCoverListThumbWidth;
	targetThumbHeight = kBlioCoverListThumbHeight;
	
	scaledTargetThumbWidth = round(targetThumbWidth * scaleFactor);
	scaledTargetThumbHeight = round(targetThumbHeight * scaleFactor);
	
//	NSString * pixelSpecificKey = [NSString stringWithFormat:@"%@%ix%i",BlioBookThumbnailPrefix,scaledTargetThumbWidth,scaledTargetThumbHeight];
	//NSLog(@"Pixelspecifickey: %@", pixelSpecificKey);
	
    NSData *imageData = [self dataFromXPSAtPath:@"Metadata/Thumbnail.jpg"];

    UIImage *aCoverImage = [UIImage imageWithData:imageData];
    if (aCoverImage) {
        return aCoverImage;
    } else {
        return [self missingCoverImageOfSize:CGSizeMake(targetThumbWidth, targetThumbHeight)];
		return nil;
    }
}

- (UIImage *)missingCoverImageOfSize:(CGSize)size {
    if(UIGraphicsBeginImageContextWithOptions != nil) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIImage *missingCover = [UIImage imageNamed:@"booktexture-nocover.png"];
    [missingCover drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    NSString *titleString = self.title;
    NSUInteger maxTitleLength = 100;
    if ([titleString length] > maxTitleLength) {
        titleString = [NSString stringWithFormat:@"%@...", [titleString substringToIndex:maxTitleLength]];
    }
    
    CGSize fullSize = [[UIScreen mainScreen] bounds].size;
    CGFloat pointSize = roundf(fullSize.height / 8.0f);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(size.width / fullSize.width, size.height / fullSize.height);
    
    UIEdgeInsets titleInsets = UIEdgeInsetsMake(fullSize.height * 0.2f, fullSize.width * 0.2f, fullSize.height * 0.2f, fullSize.width * 0.1f);
    CGRect titleRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, fullSize.width, fullSize.height), titleInsets);
    
    BOOL fits = NO;
    
    
    while (!fits && pointSize >= 2) {
        CGSize size = [titleString sizeWithFont:[UIFont systemFontOfSize:pointSize]];
        if ((size.height <= titleRect.size.height) && (size.width <= titleRect.size.width)) {
            fits = YES;
        } else {
            pointSize -= 1.0f;
        }
    }
    
    CGContextConcatCTM(ctx, scaleTransform);
    CGContextClipToRect(ctx, titleRect); // if title won't fit at 2 points it gets clipped
    
    CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.919 green:0.888 blue:0.862 alpha:0.8f].CGColor);
    CGContextBeginTransparencyLayer(ctx, NULL);
    CGContextSetShadow(ctx, CGSizeMake(0, -1*scaleTransform.d), 0);
    //[renderer drawString:titleString inContext:ctx atPoint:titleRect.origin pointSize:pointSize maxWidth:titleRect.size.width flags:flags];
    CGContextEndTransparencyLayer(ctx);
    
    CGContextSetRGBFillColor(ctx, 0.9f, 0.9f, 1, 0.8f);
	[titleString drawAtPoint:titleRect.origin withFont:[UIFont systemFontOfSize:pointSize]];
//    [renderer drawString:titleString inContext:ctx atPoint:titleRect.origin pointSize:pointSize maxWidth:titleRect.size.width flags:flags];
//    [renderer release];
    
    UIImage *aCoverImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return aCoverImage;
}



- (NSData *)dataFromXPSAtPath:(NSString *)path {
    return [self dataForComponentAtPath:path];
}

- (NSData *)dataForComponentAtPath:(NSString *)path {
    NSString *componentPath = path;
    NSString *directory = [path stringByDeletingLastPathComponent];
    NSString *filename  = [path lastPathComponent];
    NSString *extension = [[path pathExtension] uppercaseString];
	
    BOOL encrypted = NO;
    BOOL gzipped = NO;
    BOOL mapped = NO;
    BOOL cached = NO;
    
    // TODO: Make sure these checks are ordered from most common to least common for efficiency
    if ([filename isEqualToString:@"Rights.xml"]) {
        if (self.bookIsEncrypted) {
            encrypted = YES;
            gzipped = YES;
        }
    } else if ([extension isEqualToString:[BlioXPSComponentExtensionFPage uppercaseString]]) {
        if (self.bookIsEncrypted) {
            encrypted = YES;
            gzipped = YES;
            componentPath = [[BlioXPSEncryptedPagesDir stringByAppendingPathComponent:[path lastPathComponent]] stringByAppendingPathExtension:BlioXPSComponentExtensionEncrypted];
        } else {
            componentPath = [[self xpsPagesDirectory] stringByAppendingPathComponent:path];
        }
		
        mapped = YES;
        cached = YES;
    } else if ([directory isEqualToString:BlioXPSEncryptedImagesDir] && ([extension isEqualToString:@"JPG"] || [extension isEqualToString:@"PNG"])) { 
        if (self.bookIsEncrypted) {
            encrypted = YES;
            componentPath = [path stringByAppendingPathExtension:BlioXPSComponentExtensionEncrypted];
        }
        cached = YES;
    } else if ([directory isEqualToString:BlioXPSEncryptedTextFlowDir]) {  
        if (![path isEqualToString:@"/Documents/1/Other/KNFB/Flow/Sections.xml"]) {
            if (self.bookIsEncrypted) {
                encrypted = YES;
                gzipped = YES;
            }
            cached = YES;
        }
    } else if ([directory isEqualToString:BlioXPSEncryptedPagesDir]) {
        if (self.bookIsEncrypted) {
            encrypted = YES;
            gzipped = YES;
        }
        cached = YES;
    } else if ([path isEqualToString:BlioXPSEncryptedUriMap]) {
        if (self.bookIsEncrypted) {
            encrypted = YES;
            gzipped = YES;
        }
    }
	
    if (cached) {
        NSData *cacheData = [self.componentCache objectForKey:componentPath];
        if ([cacheData length]) {
            return cacheData;
        }
    }
    
    NSData *componentData = [self rawDataForComponentAtPath:componentPath];
/*	
    if (encrypted) {
        BOOL decrypted = NO;
        if (!decryptionAvailable) {
            // Check if this is first run
            if (self.drmSessionManager && decryptionAvailable) {
                if ([self.drmSessionManager decryptData:componentData]) {
                    decrypted = YES;
                }
            }
        } else {
            if ([self.drmSessionManager decryptData:componentData]) {
                decrypted = YES;
            }
        }
       
        if (!decrypted) {
			NSLog(@"Error whilst decrypting data at path %@", componentPath);
            return nil;
        }
    }
  */  
    if (gzipped) {
        componentData = [self decompressWithGZipCompression:componentData];
    }
    
    if (mapped) {
        componentData = [self replaceMappedResources:componentData];
    }
    
    if (cached && [componentData length]) {
        [self.componentCache setObject:componentData forKey:componentPath cost:[componentData length]];
    }
    
    if (![componentData length]) {
        NSLog(@"Zero length data returned in dataForComponentAtPath: %@", path);
    }
    
    return componentData;
    
}


- (NSData *)replaceMappedResources:(NSData *)data {
    NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:[inputString length]];
	
    NSString *GRIDROW = @"Grid.Row=\"";
    NSString *CLOSINGQUOTE = @"\"";
    
    NSScanner *aScanner = [NSScanner scannerWithString:inputString];
    
    while ([aScanner isAtEnd] == NO)
    {
        NSUInteger startPos = [aScanner scanLocation];
        [aScanner scanUpToString:GRIDROW intoString:NULL];
        NSUInteger endPos = [aScanner scanLocation];
        NSRange prefixRange = NSMakeRange(startPos, endPos - startPos);
        [outputString appendString:[inputString substringWithRange:prefixRange]];
        
        if ([aScanner isAtEnd] == NO) {
            // Skip the gridrow entry
            [aScanner scanString:GRIDROW intoString:NULL];
            
            // Read the row digit, insert the lookup and advance passed the closing quote
            NSInteger anInteger;
            if ([aScanner scanInteger:&anInteger]) {
                if (anInteger < [self.uriMap count]) {
                    [outputString appendString:[NSString stringWithFormat:@"ImageSource=\"%@\" ", [self.uriMap objectAtIndex:anInteger]]];
                } else {
                    NSLog(@"Warning: could not find mapped resource for Grid.Row %d. Mapping count is %d", anInteger, [self.uriMap count]);
                }
            }
            // Skip the closing quote
            [aScanner scanString:CLOSINGQUOTE intoString:NULL];
        }
    }
    [inputString release];
    
    if ([outputString length]) {
        data = [outputString dataUsingEncoding:NSUTF8StringEncoding];
    }
    [outputString release];
    
    return data;
}

/*
- (NSData *)manifestDataForKey:(NSString *)key {
    NSData *data = nil;
    NSDictionary *manifestEntry = [[self valueForKeyPath:[NSString stringWithFormat:@"manifest.%@", key]] retain];
	NSLog(@"Manifest: %@", manifestEntry);
    if(manifestEntry) {
        NSString *location = BlioManifestEntryLocationBundle;
        NSString *path = self.xpsPath;
        if (location && path) {
            if ([location isEqualToString:BlioManifestEntryLocationFileSystem]) {
                data = [self dataFromFileSystemAtPath:path];
            } else if ([location isEqualToString:BlioManifestEntryLocationXPS]) {
                data = [self dataFromXPSAtPath:path];
            } else if ([location isEqualToString:BlioManifestEntryLocationTextflow]) {
                data = [self dataFromTextFlowAtPath:path];
            }
        }
    }
    [manifestEntry release];
    return data;
}
*/

- (NSString *)extractFixedDocumentPath:(NSData *)data {
	NSString *docRefString = nil;
	
	if (data) {
		NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		NSString *DOCREF = @"<DocumentReference";
		NSString *QUOTE = @"\"";
		
		NSScanner *aScanner = [NSScanner scannerWithString:inputString];
		
		while ([aScanner isAtEnd] == NO)
		{
			
			[aScanner scanUpToString:DOCREF intoString:NULL];
			[aScanner scanString:DOCREF intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:NULL];
			[aScanner scanString:QUOTE intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:&docRefString];
			break;
		}
		[inputString release];
	}
	
	return docRefString;
}

- (NSString *)extractFixedPagesPath:(NSData *)data {
	NSString *pageContentString = nil;
	NSString *fixedPagesString = nil;
	
	if (data) {
		NSString *inputString = [[NSString alloc] initWithBytesNoCopy:(void *)[data bytes] length:[data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
		
		NSString *PAGECONTENT = @"<PageContent";
		NSString *QUOTE = @"\"";
		
		NSScanner *aScanner = [NSScanner scannerWithString:inputString];
		
		while ([aScanner isAtEnd] == NO)
		{
			
			[aScanner scanUpToString:PAGECONTENT intoString:NULL];
			[aScanner scanString:PAGECONTENT intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:NULL];
			[aScanner scanString:QUOTE intoString:NULL];
			[aScanner scanUpToString:QUOTE intoString:&pageContentString];
			
			if (pageContentString) {
				fixedPagesString = [NSString stringWithString:[pageContentString stringByDeletingLastPathComponent]];
				break;
			}
			
		}
		[inputString release];
	}
	
	return fixedPagesString;
}


- (BOOL)bookIsEncrypted {
    if (nil == bookIsEncrypted) {
//        bookIsEncrypted = [NSNumber numberWithBool:[self.book isEncrypted]];
        bookIsEncrypted = [NSNumber numberWithBool:NO];
    }
    
    return [bookIsEncrypted boolValue];
}

- (NSString *)xpsPagesDirectory {
	if (!xpsPagesDirectory) {
		NSData *sequenceData = [self dataForComponentAtPath:BlioXPSSequenceFile];
		NSString *fixedDocumentPath = [self extractFixedDocumentPath:sequenceData];
		
		if (fixedDocumentPath) {
			NSData *fixedDocumentData = [self dataForComponentAtPath:fixedDocumentPath];
			NSString *pagesPath = [self extractFixedPagesPath:fixedDocumentData];
			if ([[pagesPath substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
				xpsPagesDirectory = pagesPath;
			} else {
				if (![[fixedDocumentPath substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"/"]) {
					fixedDocumentPath = [NSString stringWithFormat:@"/%@", fixedDocumentPath];
				}
				xpsPagesDirectory = [[fixedDocumentPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:pagesPath];
			}
			[xpsPagesDirectory retain];
		}
		
	}
	
	return xpsPagesDirectory ? : @"";
}


#pragma mark -
#pragma mark Decompression

- (NSData *)decompressWithRawDeflate:(NSData *)data {
    return [self decompress:data windowBits:-15];
}

- (NSData *)decompressWithGZipCompression:(NSData *)data {
    return [self decompress:data windowBits:31];
}

- (NSData *)decompress:(NSData *)data windowBits:(NSInteger)windowBits {
    
	int ret;
	unsigned bytesDecompressed;
	z_stream strm;
	const int BUFSIZE=16384;
	unsigned char outbuf[BUFSIZE];
	NSMutableData* outData = [[NSMutableData alloc] init];
	
	// Read the gzip header.
	// TESTING
	//unsigned char ID1 = inBuffer[0];  // should be x1f
	//unsigned char ID2 = inBuffer[1];  // should be x8b
	//unsigned char CM = inBuffer[2];   // should be 8
	
	// Allocate inflate state.
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.avail_in = 0;
	strm.next_in = Z_NULL;
	
    [inflateLock lock];
    
	ret = XPS_inflateInit2(&strm, windowBits);
	
	if (ret != Z_OK) {
        [inflateLock unlock];
        [outData release];
		return nil;
    }
	
	strm.avail_in = [data length];
	strm.next_in = (Bytef *)[data bytes];
	// Inflate until the output buffer isn't full
	do {
		strm.avail_out = BUFSIZE;
		strm.next_out = outbuf;
		ret = XPS_inflate(&strm,Z_NO_FLUSH); 
		// ret should be Z_STREAM_END
		switch (ret) {
			case Z_NEED_DICT:
				//ret = Z_DATA_ERROR;
			case Z_DATA_ERROR:
			case Z_MEM_ERROR:
				XPS_inflateEnd(&strm);
                [inflateLock unlock];
                [outData release];
				return nil;
		}
		bytesDecompressed = BUFSIZE - strm.avail_out;
		NSData* data = [[NSData alloc] initWithBytesNoCopy:outbuf length:bytesDecompressed freeWhenDone:NO];
		[outData appendData:data];
        [data release];
	}
	while (strm.avail_out == 0);
	XPS_inflateEnd(&strm);
	
    [inflateLock unlock];
	
	if (ret == Z_STREAM_END || ret == Z_OK)
		return [outData autorelease];
    
    [outData release];
	return nil;
}

@end

#pragma mark -
#pragma mark BlioXPSBitmapReleaseCallback

@implementation BlioXPSBitmapReleaseCallback

@synthesize data;

- (void)dealloc {
    if (self.data) {
        //NSLog(@"Release: %p", self.data);
        XPS_ReleaseImageMemory(self.data);
    }
    [super dealloc];
}

@end

