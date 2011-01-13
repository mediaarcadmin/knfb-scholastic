//
//  BITSyncProcess.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BITSyncEngineProtocol.h"

@interface BITSyncProcess : NSObject {
	NSArray *itemsAncestry;	
	NSArray *itemsA;
	NSArray *itemsB;
	NSArray *lastModifiedDates;
	
	id<BITSyncEngineProtocol> syncEngine;
}

- (BOOL)process:(NSError *)error;

@end
