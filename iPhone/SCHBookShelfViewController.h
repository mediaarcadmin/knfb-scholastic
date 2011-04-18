//
//  SCHBookShelfViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SCHBookShelfGridView.h"
#import "MRGridViewDelegate.h"
#import "MRGridViewDataSource.h"
#import "KNFBTimeOrderedCache.h"
#import "SCHProfileItem.h"

@class SCHCustomNavigationBar;

@interface SCHBookShelfViewController : UIViewController <MRGridViewDelegate, MRGridViewDataSource> {

}

@property (nonatomic, retain) IBOutlet SCHBookShelfGridView *gridView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UIViewController *themePickerContainer;

@property (nonatomic, retain) KNFBTimeOrderedCache *componentCache;

@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, retain) SCHProfileItem *profileItem;

@end
