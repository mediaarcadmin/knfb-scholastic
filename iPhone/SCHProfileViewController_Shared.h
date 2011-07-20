//
//  SCHProfileViewController.h
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCHProfileViewCell.h"

@class SCHLoginPasswordViewController;

@interface SCHProfileViewController_Shared : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, SCHProfileViewCellDelegate> {
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


@end
