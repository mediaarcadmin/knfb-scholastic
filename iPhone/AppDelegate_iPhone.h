//
//  AppDelegate_iPhone.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"

@interface AppDelegate_iPhone : AppDelegate_Shared {
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

