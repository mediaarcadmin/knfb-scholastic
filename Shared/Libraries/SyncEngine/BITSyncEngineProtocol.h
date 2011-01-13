//
//  BITSyncEngineProtocol.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BITSyncEngineProtocol

- (void)syncAncestry:(NSDictionary *)ancestry itemA:(NSDictionary *)itemA itemB:(NSDictionary *)itemB lastModified:(NSString *)lastModified error:(NSError *)error;
- (void)syncItemA:(NSDictionary *)itemA itemB:(NSDictionary *)itemB lastModified:(NSString *)lastModified error:(NSError *)error;

@end
