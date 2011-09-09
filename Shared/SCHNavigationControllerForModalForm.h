//
//  SCHNavigationControllerForModalForm.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

// Allows the use of a NavigationController in a modal form, dismissing the
// keyboard when pushing new ViewControllers into the navigation controller.

// Note: this is polish for iOS4.3+ only. Older OS versions require the user to
// press the keyboard dismiss button.

@interface SCHNavigationControllerForModalForm : UINavigationController {}
@end
