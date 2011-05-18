//
//  AppDelegate_iPad.h
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"
#import "SCHCustomNavigationBar.h"

@class SCHProfileViewController_iPad;

@interface AppDelegate_iPad : AppDelegate_Shared {

}

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet SCHCustomNavigationBar *customNavigationBar;

@end

