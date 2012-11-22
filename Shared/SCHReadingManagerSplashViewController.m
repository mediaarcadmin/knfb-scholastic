//
//  SCHReadingManagerSplashViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 22/11/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHReadingManagerSplashViewController.h"

@interface SCHReadingManagerSplashViewController ()

@end

@implementation SCHReadingManagerSplashViewController

@synthesize messageLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messageLabel.text = NSLocalizedString(@"LOADING...", nil);
    }
    return self;
}

- (void)dealloc
{
    [messageLabel release], messageLabel = nil;

    [super dealloc];
}

@end
