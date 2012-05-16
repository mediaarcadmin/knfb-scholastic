//
//  SCHXPSProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHBookIdentifier.h"
#import "SCHAppBook.h"
#import "SCHXPSURLProtocol.h"
#import "KNFBXPSConstants.h"
#import "SCHDrmSession.h"

@interface SCHXPSProvider()

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

@end

@implementation SCHXPSProvider

@synthesize bookIdentifier;

+ (void)initialize 
{
    if(self == [SCHXPSURLProtocol class]) {
        [SCHXPSURLProtocol registerXPSProtocol];
    }
} 	

- (void)dealloc
{  
    [bookIdentifier release], bookIdentifier = nil;
    [drmDecrypter release], drmDecrypter = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)aBookIdentifier xpsPath:(NSString *)xpsPath
{
    if (xpsPath && (self = [super initWithPath:xpsPath])) {
        bookIdentifier = [aBookIdentifier retain];
    }
    
    return self;
}

- (id<KNFBDrmBookDecrypter>)drmDecrypter
{
	if (!drmDecrypter ) {
		drmDecrypter = [[SCHDrmDecryptionSession alloc] initWithBook:self.bookIdentifier]; 
		if ([drmDecrypter bindToLicense]) { 
			decryptionAvailable = YES; 
			if (reportingStatus != kKNFBDrmBookReportingStatusComplete) { 
				reportingStatus = kKNFBDrmBookReportingStatusRequired; 
			} 
		} 
	} 
	return drmDecrypter;
}

// This is used to clear the drmDecrypter so it will bind to a license again if required
// It is called from teh License Acquisition operation
- (void)resetDrmDecrypter
{
    [drmDecrypter release], drmDecrypter = nil;
}

// Subclassed methods

- (NSString *)bookThumbnailsDirectory {
    return KNFBXPSMetaDataDir;
}

- (id<KNFBDrmBookDecrypter>)drmBookDecrypter {
    return [self drmDecrypter];
}

// Scholastic convenience methods

- (NSData *)coverThumbData {
    return [self dataForComponentAtPath:@"Metadata/Thumbnail.jpg"];
}

#pragma mark - Overriden Methods

- (UIImage *)thumbnailForPage:(NSInteger)pageNumber 
{
    // We override this method because we know thumbnails are always deflated inside scholastic books. This gives us non-blocking access to them.
    
    UIImage *thumbnail = nil;
    NSString *thumbPath = [KNFBXPSMetaDataDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", pageNumber]];
    NSData *thumbData = [self dataForComponentAtPath:thumbPath hint:kKNFBXPSProviderComponentDataHintDeflated];
    
    if (thumbData) {
        thumbnail = [UIImage imageWithData:thumbData];
    }
    
    return thumbnail;
}

@end