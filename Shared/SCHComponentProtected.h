//
//  SCHComponentProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHComponent.h"

@interface SCHComponent ()

- (id)makeNullNil:(id)object;
- (void)performOnMainThreadSync:(dispatch_block_t)block;

@end