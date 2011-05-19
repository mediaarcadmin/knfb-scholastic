//
//  SCHReadingNotesViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 03/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;
@protocol SCHReadingNotesViewControllerDelegate;

@interface SCHReadingNotesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIImageView *topShadow;
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, assign) id <SCHReadingNotesViewControllerDelegate> delegate;

// interface builder
@property (nonatomic, retain) IBOutlet UITableView *notesTableView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *notesCell;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;


- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)addNoteButtonAction:(id)sender;

@end

@protocol SCHReadingNotesViewControllerDelegate <NSObject>

@optional
- (void)readingNotesView:(SCHReadingNotesViewController *)readingNotesView didSelectNote:(NSString *)note;
- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesViewController *)readingNotesView;

@end

