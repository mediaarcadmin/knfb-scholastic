//
//  BWKReadingOptionsView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BWKTestPageViewController.h"


@interface BWKReadingOptionsView : UIViewController {

}

@property (readwrite, retain) BWKTestPageViewController *pageViewController;

- (IBAction) showBookView: (id) sender;

@end
