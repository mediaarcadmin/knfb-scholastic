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
#import "MRGridViewDataSource.h"
#import "SCHBookShelfTableViewCell.h"

@class SCHBookShelfGridView;
@class SCHCustomNavigationBar;
@class KNFBTimeOrderedCache;
@class SCHProfileItem;
@class SCHReadingViewController;
@class SCHBookIdentifier;

@interface SCHBookShelfViewController : UIViewController <MRGridViewDelegate, MRGridViewDataSource, UITableViewDelegate, SCHBookShelfTableViewCellDelegate, UITableViewDataSource> 
{
}

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *listTableView;
@property (nonatomic, retain) IBOutlet SCHBookShelfGridView *gridView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UINavigationController *themePickerContainer;
@property (nonatomic, retain) IBOutlet SCHCustomNavigationBar *customNavigationBar;
@property (nonatomic, retain) IBOutlet UIButton *gridButton;
@property (nonatomic, retain) IBOutlet UIButton *listButton;
@property (nonatomic, retain) IBOutlet UIView *listToggleView;
@property (nonatomic, retain) IBOutlet UIView *gridViewToggleView;



@property (nonatomic, retain) IBOutlet SCHBookShelfTableViewCell *listViewCell;

@property (nonatomic, retain) KNFBTimeOrderedCache *componentCache;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, retain) SCHProfileItem *profileItem;

@property (nonatomic) SCHBookSortType sortType;

- (SCHReadingViewController *)openBook:(SCHBookIdentifier *)identifier error:(NSError **)error;

@end
