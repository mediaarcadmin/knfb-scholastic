//
//  SCHBSBProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookPackageProvider.h"
#import <libEucalyptus/EucEPubZipCachingDataProvider.h>

@class SCHBookIdentifier;
@class EucEPubZipCachingDataProvider;

@interface SCHBSBProvider : EucEPubZipCachingDataProvider <SCHBookPackageProvider>

- (id)initWithBookIdentifier:(SCHBookIdentifier *)bookIdentifier path:(NSString *)bsbPath;

@end