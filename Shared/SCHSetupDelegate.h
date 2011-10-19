//
//  SCHSettingsViewControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHSettingsDelegate <NSObject>

- (void)dismissSettingsWithCompletionHandler:(dispatch_block_t)completion;

@end
