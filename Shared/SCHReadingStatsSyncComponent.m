//
//  SCHReadingStatsSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingStatsSyncComponent.h"
#import "SCHSyncComponentProtected.h"

#import "SCHLibreAccessWebService.h"

@implementation SCHReadingStatsSyncComponent

- (BOOL)synchronize
{
	return(NO);	
}

- (void)clear
{
}

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	NSLog(@"%@\n%@", method, result);
}

@end
