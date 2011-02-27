//
//  SCHSettingsViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class SCHLoginViewController;

@interface SCHSettingsViewController : UITableViewController {

}

@property (nonatomic, retain) IBOutlet SCHLoginViewController *loginController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
