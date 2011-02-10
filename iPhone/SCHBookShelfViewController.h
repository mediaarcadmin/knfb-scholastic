//
//  SCHBookShelfViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MRGridView.h"
#import "MRGridViewDelegate.h"
#import "MRGridViewDataSource.h"
#import "SCHMultipleBookshelvesController.h"
#import "BlioTimeOrderedCache.h"

@interface SCHBookShelfViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MRGridViewDelegate, MRGridViewDataSource> {

}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet MRGridView *gridView;

@property (nonatomic, assign) SCHMultipleBookshelvesController *bookshelvesController;

@property (nonatomic, retain) BlioTimeOrderedCache *componentCache;

#ifdef LOCALDEBUG
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
#endif
@property (nonatomic, retain) NSArray *books;

- (void)bookshelfToggled:(NSUInteger)selectedSegment;


@end
