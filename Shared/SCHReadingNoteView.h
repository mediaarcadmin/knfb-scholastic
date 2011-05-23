//
//  SCHReadingNoteView.h
//  Scholastic
//
//  Created by Gordon Christie on 19/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
//  Ported from Blio - BlioNotesView

#import <UIKit/UIKit.h>

@protocol SCHReadingNoteViewDelegate;
@class SCHNote;
@class SCHReadingView;

@interface SCHReadingNoteView : UIView {
    
}

@property (nonatomic, assign) id <SCHReadingNoteViewDelegate> delegate;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *toolbarLabel;
//@property (nonatomic, copy) NSString *page;
@property (nonatomic, retain) SCHNote *note;
@property (nonatomic, assign) SCHReadingView *readingView;

- (id)initWithNote:(SCHNote *)aNote;
- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view animated:(BOOL)animated;

@end

@protocol SCHReadingNoteViewDelegate <NSObject>

@optional

- (void)notesView:(SCHReadingNoteView *)notesView savedNote:(SCHNote *)note;
- (void)notesViewCancelled:(SCHReadingNoteView *)notesView;

@end
