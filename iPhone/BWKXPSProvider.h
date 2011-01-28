//
//  BWKXPSProvider.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XpsSdk.h"
#import "BWKXPSBook.h"

@interface BWKXPSProvider : NSObject {

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

	// XPS: XPS pages directory
	NSString *xpsPagesDirectory;
	
	// total XPS pages
	NSInteger pageCount;
	
	// xps file size
	unsigned long long fileSize;

	// first page crop rect, to prevent repeated visits to the XPS
	CGRect firstPageCrop;

	// is the book encrypted?
	NSNumber *bookIsEncrypted;
	
	NSMutableArray *uriMap;
	NSString *title;

}

// GMC: XPS file path for testing
@property (nonatomic, retain) NSString *xpsPath;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) unsigned long long fileSize;

- (id) initWithPath: (NSString *) path;
- (CGContextRef)RGBABitmapContextForPage:(NSUInteger)page
                                fromRect:(CGRect)rect
                                 minSize:(CGSize)size 
                              getContext:(id *)context;
- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;

- (UIImage *)coverThumbForList;

@end
