//
//  SCHSettingsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsSyncComponent.h"
#import "SCHSyncComponentProtected.h"

#import "SCHLibreAccessWebService.h"

@implementation SCHSettingsSyncComponent

- (BOOL)synchronize
{
	return(NO);	
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error
{
	[super method:method didFailWithError:error];
}

@end
