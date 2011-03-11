//
//  SCHRightsManager.m
//  Scholastic
//
//  Created by John S. Eddie on 10/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRightsManager.h"

#import "SCHRightsManagerDelegate.h"

@interface SCHRightsManager ()

- (void)callSuccessDelegate:(NSString *)deviceKey;
- (void)callFailureDelegate:(NSError *)error;

@end

@implementation SCHRightsManager

@synthesize delegate;

- (BOOL)joinDomain:(NSString *)authToken
{
    BOOL ret = NO;

    // set ret to YES if all is well
    ret = YES;
    
    return(ret);
}

// you must call callSuccessDelegate: or callFailureDelegate: on completion of async operation

- (void)callSuccessDelegate:(NSString *)deviceKey
{
    if([(id)self.delegate respondsToSelector:@selector(rightsManager:didComplete:)] == YES) {
        [(id)self.delegate rightsManager:self didComplete:deviceKey];		
    }        
}

- (void)callFailureDelegate:(NSError *)error
{
    if([(id)self.delegate respondsToSelector:@selector(rightsManager:didFailWithError:)] == YES) {
        [(id)self.delegate rightsManager:self didFailWithError:error];		
    }	    
}

@end
