//
//  SCHBookShelfGridViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridViewCell.h"

#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHBookCoverView.h"

@interface SCHBookShelfGridViewCell ()

@end;

@implementation SCHBookShelfGridViewCell

@synthesize bookCoverView;
@synthesize identifier;
@synthesize isNewBook;
@synthesize loading;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier 
{
	if ((self = [super initWithFrame:frame reuseIdentifier:aReuseIdentifier])) {
        self.bookCoverView = [[[SCHBookCoverView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 4, self.frame.size.height - 22)] autorelease];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 40;
        } else {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 0;
        }
        
        self.bookCoverView.coverViewMode = SCHBookCoverViewModeGridView;
        
        [self.deleteButton setShowsTouchWhenHighlighted:NO]; // Needed to remove a "puff" visual glitch when pushing directly into the samples shelf
        [self.contentView addSubview:self.bookCoverView];
    }
	
	return(self);
}

- (void)prepareForReuse
{
    [self.bookCoverView prepareForReuse];
    [super prepareForReuse];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	[bookCoverView release], bookCoverView = nil;
    [identifier release], identifier = nil;
    [super dealloc];
}

#pragma mark - Drawing methods

- (void)beginUpdates
{
    [self.bookCoverView beginUpdates];
}

- (void)endUpdates
{
    [self.bookCoverView endUpdates];
}

#pragma mark - Accessor methods

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
    [identifier release];
    identifier = [newIdentifier retain];
    
    [self.bookCoverView setIdentifier:self.identifier];
    [self.bookCoverView refreshBookCoverView];
}

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    self.bookCoverView.isNewBook = newIsNewBook;
}

- (void)setLoading:(BOOL)newLoading
{
    loading = newLoading;
    self.bookCoverView.loading = newLoading;
}

@end
