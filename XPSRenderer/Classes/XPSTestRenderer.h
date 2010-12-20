//
//  XPSTestRenderer.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XpsSdk.h"

//static NSString * const XPSMetaDataDir = @"/Documents/1/Metadata";
//static const CGFloat kBlioCoverListThumbHeight = 76;
//static const CGFloat kBlioCoverListThumbWidth = 53;
//static NSString * const BlioBookThumbnailPrefix = @"thumbnail";
//static NSString * const BlioXPSComponentExtensionEncrypted = @"bin";
//static NSString * const BlioXPSEncryptedUriMap = @"/Documents/1/Other/KNFB/UriMap.xml";
//static NSString * const BlioXPSEncryptedPagesDir = @"/Documents/1/Other/KNFB/Epages";
//static NSString * const BlioXPSEncryptedImagesDir = @"/Resources";
//static NSString * const BlioXPSEncryptedTextFlowDir = @"/Documents/1/Other/KNFB/Flow";
//static NSString * const BlioXPSComponentExtensionFPage = @"fpage";

//static NSString * const BlioManifestEntryLocationBundle = @"BlioManifestEntryLocationBundle";
//static NSString * const BlioManifestEntryLocationFileSystem = @"BlioManifestEntryLocationFileSystem";
//static NSString * const BlioManifestEntryLocationXPS = @"BlioManifestEntryLocationXPS";
//static NSString * const BlioManifestEntryLocationTextflow = @"BlioManifestEntryLocationTextflow";

@interface XPSTestRenderer : NSObject {

	// makes sure we don't have 2 instances of the XPS_Convert and its setup/callback 
	// happening at the same time
    NSLock *renderingLock;
	
	// for accessing components via the XPS_GetFixedPageProperties 
	// call - this can happen concurrently with rendering but 2 XPS_GetFixedPageProperties 
	// calls shouldn't be made concurrently
    NSLock *contentsLock;
    
	// stops us accessing the built in inflate method concurrently (used when we are 
	// accessing components inside the XPS, not when we are rendering)
	NSLock *inflateLock;

	// XPS: detailed raster information
	RasterImageInfo *imageInfo;

	// XPS: XPS handle, returned by XPS_Open
	XPS_HANDLE xpsHandle;

	// XPS: fixed page size information
	FixedPageProperties properties;

	// total XPS pages
	NSInteger pageCount;

	// first page crop rect, to prevent repeated visits to the XPS
	CGRect firstPageCrop;


}

// GMC: XPS file path for testing
@property (nonatomic, retain) NSString *xpsPath;
@property (nonatomic) NSInteger pageCount;

- (id) initWithPath: (NSString *) path;
- (CGContextRef)RGBABitmapContextForPage:(NSUInteger)page
                                fromRect:(CGRect)rect
                                 minSize:(CGSize)size 
                              getContext:(id *)context;
- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;

@end
