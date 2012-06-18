//
//  SCHSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHComponent.h"
#import "SCHComponentProtected.h"

@implementation SCHComponent

@synthesize delegate;

- (void)clearComponent
{
    NSAssert(NO, @"SCHComponent:clearComponent needs to be overidden in sub-classes");
}

- (void)completeWithSuccessMethod:(NSString *)method 
                           result:(NSDictionary *)result 
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
	if([(id)self.delegate respondsToSelector:@selector(component:didCompleteWithResult:)]) {
		[(id)self.delegate component:self didCompleteWithResult:nil];		
	}	
}

- (void)completeWithFailureMethod:(NSString *)method 
                            error:(NSError *)error 
                      requestInfo:(NSDictionary *)requestInfo 
                           result:(NSDictionary *)result
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
	NSLog(@"%@\n%@", (method != nil ? method : @"no method"), (error != nil ? error : @"no error"));
    
	if([(id)self.delegate respondsToSelector:@selector(component:didFailWithError:)]) {
		[(id)self.delegate component:self didFailWithError:error];		
	}
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
      userInfo:(NSDictionary *)userInfo
{	
    NSAssert(NO, @"SCHComponent:method:didCompleteWithResult:userInfo needs to be overidden in sub-classes");
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
    NSAssert(NO, @"SCHComponent:method:didFailWithError:requestInfo:result needs to be overidden in sub-classes");
}

#pragma mark - Private methods

- (id)makeNullNil:(id)object
{
	return(object == [NSNull null] ? nil : object);
}

- (void)performOnMainThreadSync:(dispatch_block_t)block
{
    if (block != nil) {
        if ([NSThread isMainThread] == YES) {
            block();				            
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }    
    }
}

@end
