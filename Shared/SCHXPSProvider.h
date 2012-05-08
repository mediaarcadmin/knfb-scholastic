//
//  SCHXPSProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBXPSProvider.h"
#import "SCHBookPackageProvider.h"

@class NSManagedObjectContext;
@class SCHBookIdentifier;
@protocol SCHBookPackageProvider;

@interface SCHXPSProvider : KNFBXPSProvider <SCHBookPackageProvider> {
    SCHBookIdentifier *bookIdentifier;
	id<KNFBDrmBookDecrypter> drmDecrypter;
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier xpsPath:(NSString *)xpsPath;

// Scholastic convenience methods

- (NSData *)coverThumbData;
- (void)resetDrmDecrypter;
- (BOOL)containsEmbeddedEPub;

@end