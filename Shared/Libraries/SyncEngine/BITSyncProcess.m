//
//  BITSyncProcess.m
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import "BITSyncProcess.h"


@implementation BITSyncProcess

- (BOOL)process:(NSError *)error {
	BOOL ret = NO;
	
	if(itemsA == nil || itemsB == nil || lastModifiedDates == nil)
		return(ret);
	
	NSUInteger count = [itemsA count];
	
	if(count != [itemsB count] || count != [lastModifiedDates count])
		return(ret);
	
	if(itemsAncestry == nil) {
		for(NSUInteger i = 0; i < count; i++) {		
			[syncEngine syncItemA:[itemsA objectAtIndex:i] itemB:[itemsB objectAtIndex:i] lastModified:[lastModifiedDates objectAtIndex:i] error:error];
		}
	} else {	 	
		if(count != [itemsAncestry count])
			return(ret);

		for(NSUInteger i = 0; i < count; i++) {				
			[syncEngine syncAncestry:[itemsAncestry objectAtIndex:i] itemA:[itemsA objectAtIndex:i] itemB:[itemsB objectAtIndex:i] lastModified:[lastModifiedDates objectAtIndex:i] error:error];
		}  
	}
	ret = YES;

	return(ret);
}

@end
