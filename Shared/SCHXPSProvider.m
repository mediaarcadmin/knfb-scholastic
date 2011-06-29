//
//  SCHXPSProvider.m
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHXPSURLProtocol.h"
#import "KNFBXPSConstants.h"
#import "SCHDrmSession.h"

@interface SCHXPSProvider()

@property (nonatomic, retain) NSString *bookISBN;

@end

@implementation SCHXPSProvider

@synthesize bookISBN;

+ (void)initialize {
    if(self == [SCHXPSURLProtocol class]) {
        [SCHXPSURLProtocol registerXPSProtocol];
    }
} 	

- (void)dealloc {  
    [bookISBN release], bookISBN = nil;
    [super dealloc];
}

- (id)initWithISBN:(NSString *)aBookISBN xpsPath:(NSString *)xpsPath
{
    if (xpsPath && (self = [super initWithPath:xpsPath])) {
        bookISBN = [aBookISBN copy];
    }
    
    return self;
}

- (id<KNFBDrmBookDecrypter>)drmDecrypter {
	if (!drmDecrypter ) {
		drmDecrypter = [[SCHDrmDecryptionSession alloc] initWithBook:self.bookISBN]; 
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