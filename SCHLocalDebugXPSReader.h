//
//  SCHLocalDebugXPSReader.h
//  Scholastic
//
//  Created by Gordon Christie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XpsSdk.h"

@interface SCHLocalDebugXPSReader : NSObject {
	
	// stops us accessing the built in inflate method concurrently (used when we are 
	// accessing components inside the XPS, not when we are rendering)
	NSLock *inflateLock;

	// XPS: XPS handle, returned by XPS_Open
	XPS_HANDLE xpsHandle;
	
	// XPS: XPS pages directory
	NSString *xpsPagesDirectory;
	
}

@property (nonatomic, retain) NSString *ISBN;
@property (nonatomic) int pageCount;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic) unsigned long long fileSize;
@property (nonatomic, retain) NSString *type;


- (id) initWithPath: (NSString *) path;

@end
