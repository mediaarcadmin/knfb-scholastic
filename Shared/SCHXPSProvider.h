//
//  SCHXPSProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBXPSProvider.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;

@interface SCHXPSProvider : KNFBXPSProvider {
    SCHBookIdentifier *bookIdentifier;
	id<KNFBDrmBookDecrypter> drmDecrypter;
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier xpsPath:(NSString *)xpsPath;

- (NSDictionary *)pageNumbers:(NSRange)pageIndexRange error:(NSError **)error;

// Scholastic convenience methods

- (NSData *)coverThumbData;

@end