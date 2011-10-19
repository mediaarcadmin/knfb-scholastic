//
//  SCHSettingsViewControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHSettingsDelegate <NSObject>

- (void)dismissSettingsAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;
- (void)popToRootViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;

@end
