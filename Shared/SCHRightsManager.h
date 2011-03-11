//
//  SCHRightsManager.h
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHRightsManagerDelegate;

@interface SCHRightsManager : NSObject {
    
}

@property (nonatomic, assign) id<SCHRightsManagerDelegate> delegate;

- (BOOL)joinDomain:(NSString *)authToken;

@end
