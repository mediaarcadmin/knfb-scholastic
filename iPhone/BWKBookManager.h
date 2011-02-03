//
//  BWKBookManager.h
//  Scholastic
//
//  Created by Gordon Christie on 02/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BWKXPSProvider.h"


@interface BWKBookManager : NSObject {

}

+ (BWKBookManager *)sharedBookManager;

- (BWKXPSProvider *)checkOutXPSProviderForBookWithPath:(NSString *)path;
- (void)checkInXPSProviderForBookWithPath:(NSString *)path;

@end
