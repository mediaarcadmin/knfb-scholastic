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
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)aBookIdentifier xpsPath:(NSString *)xpsPath
{
    if (xpsPath && (self = [super initWithPath:xpsPath])) {
        bookIdentifier = [aBookIdentifier retain];
    }
    
    return self;
}

- (id<KNFBDrmBookDecrypter>)drmDecrypter {
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

@end