//
//  SCHContentMetadataItem+Extensions.h
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCHContentMetadataItem.h"

static NSString * const kSCHContentMetadataItem = @"SCHContentMetadataItem";

@interface SCHContentMetadataItem (SCHContentMetadataItemExtensions)

- (NSArray *)annotationsContentForProfile:(NSNumber *)profileID;
- (BOOL)haveURLs;
   
@end
