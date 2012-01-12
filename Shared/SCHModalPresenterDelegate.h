//
//  SCHModalPresenterDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHModalPresenterDelegate <NSObject>

- (void)dismissModalViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;
- (void)popToRootViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;

- (void)presentWebParentToolsModallyWithToken:(NSString *)token 
                                        title:(NSString *)title 
                                   modalStyle:(UIModalPresentationStyle)style 
                        shouldHideCloseButton:(BOOL)shouldHide;

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated withSync:(BOOL)shouldSync showValidation:(BOOL)showValidation;
- (void)waitingForWebParentToolsToComplete;

@end
