//
//  SCHBookShelfTypeMenuTableController.h
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppProfile.h"

@protocol SCHBookShelfTypeMenuTableControllerDelegate;

@interface SCHBookShelfTypeMenuTableController : UITableViewController

@property (nonatomic, assign) id <SCHBookShelfTypeMenuTableControllerDelegate> delegate;

@end

@protocol SCHBookShelfTypeMenuTableControllerDelegate <NSObject>

- (SCHAppProfile *)appProfileForbookShelfTypeController;
- (void)bookShelfTypeControllerSelectedListView:(SCHBookShelfTypeMenuTableController *)typeController;
- (void)bookShelfTypeControllerSelectedGridView:(SCHBookShelfTypeMenuTableController *)typeController;
- (void)bookShelfTypeControllerSelectedCancel:(SCHBookShelfTypeMenuTableController *)typeController;

@end