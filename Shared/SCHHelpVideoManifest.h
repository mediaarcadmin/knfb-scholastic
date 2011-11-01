//
//  SCHHelpVideoManifest.h
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHHelpVideoManifest : NSObject

@property (nonatomic, retain) NSMutableDictionary *manifestURLs;

- (NSString *)olderURLForCurrentDevice;
- (NSString *)youngerURLForCurrentDevice;
- (NSDictionary*)itemsForCurrentDevice;

@end

