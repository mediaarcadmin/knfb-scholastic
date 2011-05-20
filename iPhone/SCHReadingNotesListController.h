//
//  SCHReadingNotesListController.h
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;
@protocol SCHReadingNotesListControllerDelegate;

#pragma mark - Interface

@interface SCHReadingNotesListController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *topShadow;
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, assign) id <SCHReadingNotesListControllerDelegate> delegate;

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *notesCell;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;


- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender;
- (IBAction)editNotesButtonAction:(UIBarButtonItem *)sender;

@end

#pragma mark - Delegate 

@protocol SCHReadingNotesListControllerDelegate <NSObject>

@optional
- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didSelectNote:(NSString *)note;
- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesListController *)readingNotesView;

@end

