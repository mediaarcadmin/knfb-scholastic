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
//#import "SCHAsyncBookCoverImageView.h"
#import "SCHBookCoverView.h"

@interface SCHBookShelfGridViewCell ()

@property (nonatomic, assign) BOOL coalesceRefreshes;
@property (nonatomic, assign) BOOL needsRefresh;

- (void)deferredRefreshCell;

@end;

@implementation SCHBookShelfGridViewCell

@synthesize bookCoverView;
@synthesize thumbTintView;
@synthesize progressView;
@synthesize identifier;
@synthesize trashed;
@synthesize coalesceRefreshes;
@synthesize needsRefresh;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)aReuseIdentifier 
{
	if ((self = [super initWithFrame:frame reuseIdentifier:aReuseIdentifier])) {
        self.bookCoverView = [[SCHBookCoverView alloc] initWithFrame:CGRectZero];
        self.bookCoverView.backgroundColor = [UIColor orangeColor];
//        self.bookCoverView.coverSize = CGSizeMake(self.frame.size.width - 4, self.frame.size.height - 22);
        self.bookCoverView.frame = CGRectMake(0, 0, self.frame.size.width - 4, self.frame.size.height - 22);
        self.bookCoverView.topInset = 0;
        self.bookCoverView.leftRightInset = 0;
//        self.bookCoverView.identifier = self.identifier;
        [self.contentView addSubview:self.bookCoverView];
		
		self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10)] autorelease];
		[self.contentView addSubview:self.progressView];
		self.progressView.hidden = NO;		
    }
	
	return(self);
}

- (void)prepareForReuse
{
    // FIXME: something odd is going on here
    // being called even for new cells!
    [self.bookCoverView prepareForReuse];
    [super prepareForReuse];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
	[bookCoverView release], bookCoverView = nil;
	[thumbTintView release], thumbTintView = nil;
	[progressView release], progressView = nil;
    [identifier release], identifier = nil;
    [super dealloc];
}

#pragma mark - Drawing methods

//- (void)layoutSubviews 
//{
//    [super layoutSubviews];
////    [UIView setAnimationsEnabled:NO];
//    
//    self.bookCoverView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
//	
//    if (self.progressView.hidden == NO) {
//        self.progressView.frame = CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10);
//    }
//    
////    [UIView setAnimationsEnabled:YES];
//}

- (void)beginUpdates
{
    self.coalesceRefreshes = YES;
}

- (void)endUpdates
{
    self.coalesceRefreshes = NO;
    if (self.needsRefresh) {
        [self deferredRefreshCell];
    }
}

- (void)refreshCell
{
    if (self.coalesceRefreshes) {
        self.needsRefresh = YES;
    } else {
        [self deferredRefreshCell];
    }
}

- (void)deferredRefreshCell
{
    NSManagedObjectContext *context = [(id)[[UIApplication sharedApplication] delegate] managedObjectContext];
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:context];    
	// image processing
    [self.bookCoverView refreshBookCoverView];
    
	[self setNeedsDisplay];
    
	// book status
    if (self.trashed) {
        self.thumbTintView.hidden = NO;
        self.progressView.hidden = YES;
    } else {
        switch ([book processingState]) {
            case SCHBookProcessingStateDownloadStarted:
            case SCHBookProcessingStateDownloadPaused:
                self.thumbTintView.hidden = NO;
                self.progressView.hidden = NO;
                [self.progressView setProgress:[book currentDownloadedPercentage]];            
                break;
            case SCHBookProcessingStateReadyToRead:
                self.thumbTintView.hidden = YES;
                self.progressView.hidden = YES;
                break;
            default:
                self.thumbTintView.hidden = NO;
                self.progressView.hidden = YES;
                break;
        }
    }	
    
    self.bookCoverView.frame = CGRectMake(2, 0, self.frame.size.width - 4, self.frame.size.height - 22);
	
    if (self.progressView.hidden == NO) {
        self.progressView.frame = CGRectMake(10, self.frame.size.height - 42, self.frame.size.width - 20, 10);
    }

    self.needsRefresh = NO;
}	

#pragma mark - Accessor methods

- (void)setIdentifier:(SCHBookIdentifier *)newIdentifier
{	
	if ([newIdentifier isEqual:identifier]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookDownloadPercentageUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookStatusUpdate" object:nil];
    
    [identifier release];
    identifier = [newIdentifier retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePercentage:) 
                                                 name:@"SCHBookDownloadPercentageUpdate" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForCellUpdateFromNotification:)
                                                 name:@"SCHBookStateUpdate"
                                               object:nil];
    
    [self.bookCoverView setIdentifier:self.identifier];
    [self refreshCell];        
}

- (void)setTrashed:(BOOL)newTrashed
{
    trashed = newTrashed;
    [self refreshCell];
}

#pragma mark - Private methods

- (void)checkForCellUpdateFromNotification:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        [self refreshCell];
    }
}	

- (void)updatePercentage:(NSNotification *)notification
{
    SCHBookIdentifier *bookIdentifier = [[notification userInfo] objectForKey:@"bookIdentifier"];
    if ([bookIdentifier isEqual:self.identifier]) {
        float newPercentage = [(NSNumber *) [[notification userInfo] objectForKey:@"currentPercentage"] floatValue];
        [self.progressView setProgress:newPercentage];
        [self.progressView setHidden:NO];
    }
}

@end
