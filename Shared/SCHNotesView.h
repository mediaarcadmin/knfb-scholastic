//
//  SCHNotesView.h
//  Scholastic
//
//  Created by Gordon Christie on 19/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
//  Ported from Blio - BlioNotesView

#import <UIKit/UIKit.h>

@protocol SCHNotesViewDelegate;

@interface SCHNotesView : UIView {
    
}

@property (nonatomic, assign) id <SCHNotesViewDelegate> delegate;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *toolbarLabel;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, copy) NSString *noteText;

//- (id)initWithRange:(BlioBookmarkRange *)aRange note:(NSManagedObject *)aNote;
- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view animated:(BOOL)animated;

@end

@protocol SCHNotesViewDelegate <NSObject>

@optional

- (void)notesViewSaved:(SCHNotesView *)notesView;
- (void)notesViewCancelled:(SCHNotesView *)notesView;

@end
