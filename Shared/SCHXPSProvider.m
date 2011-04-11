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

- (id)initWithISBN:(NSString *)aBookISBN {
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    SCHAppBook *book = [bookManager bookWithIdentifier:aBookISBN];
    NSString *xpsPath = [book xpsPath];
    
    if (xpsPath && (self = [super initWithPath:xpsPath])) {
        bookISBN = [aBookISBN copy];
    }
    
    return self;
}

- (id<KNFBDrmBookDecrypter>)drmDecrypter {
#if implemented
	if (!drmDecrypter ) {
		drmDecrypter = [[SCHDrmSessionManager alloc] initWithISBN:self.bookISBN]; 
		if ([drmDecrypter bindToLicense]) { 
			decryptionAvailable = YES; 
			if (reportingStatus != kKNFBDrmBookReportingStatusComplete) { 
				reportingStatus = kKNFBDrmBookReportingStatusRequired; 
			} 
		} 
	} 
	return drmDecrypter;
#else
    return nil;
#endif
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