//
//  BITXPSProvider.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XpsSdk.h"
#import "SCHBookInfo.h"

static NSString * const XPSMetaDataDir = @"/Documents/1/Metadata";
static const CGFloat kBlioCoverListThumbHeight = 76;
static const CGFloat kBlioCoverListThumbWidth = 53;
static NSString * const BlioBookThumbnailPrefix = @"Thumbnail";
static NSString * const BlioXPSComponentExtensionEncrypted = @"bin";
static NSString * const BlioXPSEncryptedUriMap = @"/Documents/1/Other/KNFB/UriMap.xml";
static NSString * const BlioXPSEncryptedMetadata = @"/Documents/1/Other/KNFB/Metadata.xml";
static NSString * const BlioXPSEncryptedPagesDir = @"/Documents/1/Other/KNFB/Epages";
static NSString * const BlioXPSEncryptedImagesDir = @"/Resources";
static NSString * const BlioXPSEncryptedTextFlowDir = @"/Documents/1/Other/KNFB/Flow";
static NSString * const BlioXPSComponentExtensionFPage = @"fpage";
static NSString * const BlioXPSSequenceFile = @"/FixedDocumentSequence.fdseq";
static NSString * const BlioXPSFileThumbnail = @"Metadata/Thumbnail.jpg";
static NSString * const BlioXPSKNFBRightsFile = @"/Documents/1/Other/KNFB/Rights.xml";
static NSString * const BlioXPSAudiobookMetadataFile = @"/Documents/1/Other/KNFB/Audio/Audio.xml";
static NSString * const BlioXPSStoryInteractionsMetadataFile = @"/Documents/1/Other/KNFB/Interactions/Interactions.xml";
static NSString * const BlioXPSExtrasMetadataFile = @"/Documents/1/Other/KNFB/Extras/Extras.xml";



@interface BITXPSProvider : NSObject {

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
	
	// XPS metadata info
	NSString *ISBN;
	NSString *author;
	NSString *type;

	// first page crop rect, to prevent repeated visits to the XPS
	CGRect firstPageCrop;

	// is the book encrypted?
	NSNumber *bookIsEncrypted;
	
	NSMutableArray *uriMap;
	NSString *title;

}

//@property (nonatomic, retain) NSManagedObjectID *bookID;
@property (nonatomic, retain) SCHBookInfo *bookInfo;

@property (nonatomic, retain) NSString *title;
@property (nonatomic) NSInteger pageCount;
@property (nonatomic) unsigned long long fileSize;
@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *type;

- (id) initWithBookInfo: (SCHBookInfo *) bookInfo;
- (CGContextRef)RGBABitmapContextForPage:(NSUInteger)page
                                fromRect:(CGRect)rect
                                 minSize:(CGSize)size 
                              getContext:(id *)context;
- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;

- (UIImage *)coverThumbForList;
- (NSData *)coverThumbData;

- (NSData *)dataForComponentAtPath:(NSString *)path;
- (BOOL)componentExistsAtPath:(NSString *)path;

@end
