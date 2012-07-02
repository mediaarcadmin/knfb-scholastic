//
//  SCHStartingViewController.h
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHProfileSetupDelegate.h"

// Constants
extern NSString * const kSCHLoginErrorDomain;
extern NSInteger const kSCHLoginReachabilityError;
extern NSString * const kSCHSamplesErrorDomain;
extern NSInteger const kSCHSamplesUnspecifiedError;

@interface SCHStartingViewController : UIViewController <SCHProfileSetupDelegate> {}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UINavigationController *modalNavigationController;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

- (void)createInitialNavigationControllerStack;

@end
