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

@class SCHThemeNavigationBar;

@interface SCHBookShelfViewController : UIViewController <MRGridViewDelegate, MRGridViewDataSource> {

}

@property (nonatomic, retain) IBOutlet SCHBookShelfGridView *gridView;
@property (nonatomic, retain) IBOutlet UIView *loadingView;
@property (nonatomic, retain) IBOutlet UINavigationController *themePickerContainer;
@property (nonatomic, retain) IBOutlet SCHThemeNavigationBar *customNavigationBar;

@property (nonatomic, retain) KNFBTimeOrderedCache *componentCache;

@property (nonatomic, retain) NSMutableArray *books;
@property (nonatomic, retain) SCHProfileItem *profileItem;

@end
