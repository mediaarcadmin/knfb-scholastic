//
//  SCHBookPackageProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 08/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <libEucalyptus/EucEPubDataProvider.h>

@protocol SCHBookPackageProvider <EucEPubDataProvider>

@required

- (BOOL)componentExistsAtPath:(NSString *)path;
- (BOOL)isEncrypted;
- (BOOL)isValid;
- (BOOL)decryptionIsAvailable;
- (void)reportReadingIfRequired;
- (UIImage *)thumbnailForPage:(NSInteger)pageNumber;

@end

