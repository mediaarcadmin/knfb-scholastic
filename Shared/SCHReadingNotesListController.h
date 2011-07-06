//
//  SCHReadingNotesListController.h
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;
@class SCHProfileItem;
@class SCHNote;
@class SCHBookPoint;
@class SCHBookIdentifier;
@protocol SCHReadingNotesListControllerDelegate;

#pragma mark - Interface

@interface SCHReadingNotesListController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *topShadow;
}

@property (nonatomic, retain) SCHProfileItem *profile;
@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;
@property (nonatomic, assign) id <SCHReadingNotesListControllerDelegate> delegate;

// interface builder
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *notesCell;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;


- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender;
- (IBAction)editNotesButtonAction:(UIBarButtonItem *)sender;

@end

#pragma mark - Delegate 

@protocol SCHReadingNotesListControllerDelegate <NSObject>

@required
- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didSelectNote:(SCHNote *)note;
- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didDeleteNote:(SCHNote *)note;
- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesListController *)readingNotesView;
- (SCHBookPoint *)bookPointForNote:(SCHNote *)note; // returns nil if book isn't paginated yet
- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint;

@end

