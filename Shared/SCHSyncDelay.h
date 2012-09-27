//
//  SCHSyncDelay.h
//  Scholastic
//
//  Created by John S. Eddie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHSyncDelay : NSObject

@property (nonatomic, assign, readonly) BOOL delayActive;

- (void)activateDelay;
- (void)clearLastSyncDate;
- (void)clearSyncDelay;
- (void)syncStarted;
- (BOOL)shouldSync;

@end
