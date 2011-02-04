//
//  SCHSyncComponent.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SCHSyncComponent : NSObject {
	BOOL isSynchronizing;
}

@property BOOL isSynchronizing;

- (void)synchronize;

@end
