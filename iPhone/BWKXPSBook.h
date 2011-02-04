//
//  BWKXPSBook.h
//  XPSRenderer
//
//  Created by Gordon Christie on 21/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
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

@interface BWKXPSBook : NSObject {
	NSMutableDictionary *properties;
}

@property (nonatomic, retain) NSMutableDictionary *properties;

@end
