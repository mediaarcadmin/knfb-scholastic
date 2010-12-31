//
//  XPSRendererAppDelegate.h
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWKBookshelfView.h"

@interface XPSRendererAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BWKBookshelfView *bookshelfView;
	UINavigationController *navController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BWKBookshelfView *bookshelfView;
@property (nonatomic, retain) UINavigationController *navController;
@end

