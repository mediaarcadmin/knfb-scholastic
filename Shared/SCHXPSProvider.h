//
//  SCHXPSProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBXPSProvider.h"

@class NSManagedObjectContext;

@interface SCHXPSProvider : KNFBXPSProvider {
    NSString *bookISBN;
	id<KNFBDrmBookDecrypter> drmDecrypter;
}

- (id)initWithISBN:(NSString *)aBookISBN xpsPath:(NSString *)xpsPath;

// Scholastic convenience methods

- (NSData *)coverThumbData;

@end