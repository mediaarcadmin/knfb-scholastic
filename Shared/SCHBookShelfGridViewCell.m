//
//  SCHBookShelfGridViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridViewCell.h"

#import "SCHThumbnailFactory.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHBookCoverView.h"

@interface SCHBookShelfGridViewCell ()

//@property (nonatomic, assign) BOOL coalesceRefreshes;
//@property (nonatomic, assign) BOOL needsRefresh;
//
//- (void)deferredRefreshCell;

@end;

@implementation SCHBookShelfGridViewCell

@synthesize bookCoverView;
@synthesize identifier;
@synthesize trashed;
@synthesize isNewBook;
//@synthesize coalesceRefreshes;
//@synthesize needsRefresh;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier 
{
	if ((self = [super initWithFrame:frame reuseIdentifier:aReuseIdentifier])) {
        self.bookCoverView = [[SCHBookCoverView alloc] initWithFrame:CGRectZero];
//        self.bookCoverView.backgroundColor = [UIColor orangeColor];
        self.bookCoverView.frame = CGRectMake(0, 0, self.frame.size.width - 4, self.frame.size.height - 22);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 6;
        } else {
            self.bookCoverView.topInset = 0;
            self.bookCoverView.leftRightInset = 0;
        }
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
//    self.coalesceRefreshes = YES;
    [self.bookCoverView beginUpdates];
}

- (void)endUpdates
{
//    self.coalesceRefreshes = NO;
//    if (self.needsRefresh) {
//        [self deferredRefreshCell];
//    }
    [self.bookCoverView endUpdates];
}

//- (void)refreshCell
//{
//    if (self.coalesceRefreshes) {
//        self.needsRefresh = YES;
//    } else {
//        [self deferredRefreshCell];
//    }
//}
//
//- (void)deferredRefreshCell
//{
//    [self.bookCoverView deferredRefreshBookCoverView];
//    self.needsRefresh = NO;
//}	

#pragma mark - Accessor methods

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
    [identifier release];
    identifier = [newIdentifier retain];
    
    [self.bookCoverView setIdentifier:self.identifier];
    [self.bookCoverView refreshBookCoverView];
//    [self refreshCell];        
}

- (void)setTrashed:(BOOL)newTrashed
{
    trashed = newTrashed;
    self.bookCoverView.trashed = newTrashed;
}

- (void)setIsNewBook:(BOOL)newIsNewBook
{
    isNewBook = newIsNewBook;
    self.bookCoverView.isNewBook = newIsNewBook;
}

@end
