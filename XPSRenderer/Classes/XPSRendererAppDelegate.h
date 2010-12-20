//
//  XPSRendererAppDelegate.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XPSTestViewController.h"

@interface XPSRendererAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	XPSTestViewController *testViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet XPSTestViewController *testViewController;

@end

