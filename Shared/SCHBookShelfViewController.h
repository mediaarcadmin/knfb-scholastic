//
//  SCHBookShelfViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SCHProfileItem.h"
#import "MRGridViewDelegate.h"
#import "SCHBookShelfGridViewDataSource.h"
#import "SCHBookShelfTableViewCell.h"
#import "SCHAppController.h"
#import "SCHBookShelfMenuController.h"

@class SCHBookShelfGridView;
@class SCHCustomNavigationBar;
@class KNFBTimeOrderedCache;
@class SCHProfileItem;
@class SCHReadingViewController;
@class SCHBookIdentifier;

@interface SCHBookShelfViewController : UIViewController <MRGridViewDelegate, SCHBookShelfGridViewDataSource, 
UITableViewDelegate, UITableViewDataSource, SCHBookShelfTableViewCellDelegate, SCHBookShelfGridViewCellDelegate, SCHBookShelfMenuControllerDelegate> 
{
}

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *listTableView;
@property (nonatomic, retain) IBOutlet SCHBookShelfGridView *gridView;
@property (nonatomic, retain) IBOutlet UINavigationController *themePickerContainer;
@property (nonatomic, retain) IBOutlet SCHCustomNavigationBar *customNavigationBar;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, assign) id<SCHAppController> appController;

@property (nonatomic, retain) IBOutlet SCHBookShelfTableViewCell *listViewCell;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, retain) SCHProfileItem *profileItem;
@property (nonatomic, assign) BOOL showWelcome;
@property (nonatomic, assign) BOOL showingRatings;

@property (nonatomic) SCHBookSortType sortType;

- (BOOL)isBookOnShelf:(SCHBookIdentifier *)aBookIdentifier;
- (SCHReadingViewController *)openBook:(SCHBookIdentifier *)identifier error:(NSError **)error;
- (void)updateTheme;
- (void)toggleRatings;

@end
