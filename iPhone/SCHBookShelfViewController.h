//
//  SCHBookShelfViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SCHBookShelfViewController : UITableViewController <NSFetchedResultsControllerDelegate> {

@private
    NSFetchedResultsController *fetchedResultsController_;
    NSManagedObjectContext *managedObjectContext_;	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSNumber *profileID;


@end
