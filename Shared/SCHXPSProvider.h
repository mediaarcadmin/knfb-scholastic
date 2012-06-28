//
//  SCHXPSProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "KNFBXPSProvider.h"
#import <libEucalyptus/EucEPubDataProvider.h>

@class NSManagedObjectContext;
@class SCHBookIdentifier;
@protocol EucEPubDataProvider;

@interface SCHXPSProvider : KNFBXPSProvider <EucEPubDataProvider> {
    SCHBookIdentifier *bookIdentifier;
	id<KNFBDrmBookDecrypter> drmDecrypter;
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier xpsPath:(NSString *)xpsPath;
- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier xpsPath:(NSString *)xpsPath error:(NSError **)error;

// Scholastic convenience methods

- (NSData *)coverThumbData;
- (void)resetDrmDecrypter;
- (BOOL)containsEmbeddedEPub;

@end