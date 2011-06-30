//
//  SCHReadingInteractionsListController.h
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar, SCHProfileItem, SCHNote;
@class SCHReadingView;
@class SCHBookStoryInteractions;
@class SCHBookIdentifier;

@protocol SCHReadingInteractionsListControllerDelegate;

#pragma mark - Interface

@interface SCHReadingInteractionsListController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *topShadow;
}

@property (nonatomic, retain) SCHProfileItem *profile;
@property (nonatomic, retain) SCHBookStoryInteractions *bookStoryInteractions;
@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;
@property (nonatomic, assign) id <SCHReadingInteractionsListControllerDelegate> delegate;
@property (nonatomic, assign) SCHReadingView *readingView;

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *notesCell;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;


- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender;

@end

#pragma mark - Delegate 

@protocol SCHReadingInteractionsListControllerDelegate <NSObject>

@optional
- (void)readingInteractionsView:(SCHReadingInteractionsListController *)interactionsView didSelectInteraction:(NSInteger)interaction;

@end
