//
//  SCHVersionManifestEntry.h
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHVersionManifestEntry : NSObject

@property (nonatomic, retain) NSString *fromVersion;
@property (nonatomic, retain) NSString *toVersion;
@property (nonatomic, retain) NSString *forced;

@end
