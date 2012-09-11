//
//  SCHBSBContentsProvider.h
//  Scholastic
//
//  Created by Matt Farrugia on 29/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

@class SCHBSBManifest;

@protocol SCHBSBContentsProvider <NSObject>

@required
- (SCHBSBManifest *)manifest;
- (NSData *)dataForBSBComponentAtPath:(NSString *)path;

@end
