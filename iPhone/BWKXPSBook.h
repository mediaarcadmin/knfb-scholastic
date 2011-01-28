//
//  BWKXPSBook.h
//  XPSRenderer
//
//  Created by Gordon Christie on 21/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <Foundation/Foundation.h>

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

//static NSString * const BlioManifestEntryLocationBundle = @"BlioManifestEntryLocationBundle";
//static NSString * const BlioManifestEntryLocationFileSystem = @"BlioManifestEntryLocationFileSystem";
//static NSString * const BlioManifestEntryLocationXPS = @"BlioManifestEntryLocationXPS";
//static NSString * const BlioManifestEntryLocationTextflow = @"BlioManifestEntryLocationTextflow";


@interface BWKXPSBook : NSObject {
	NSMutableDictionary *properties;
}

@property (nonatomic, retain) NSMutableDictionary *properties;

@end
