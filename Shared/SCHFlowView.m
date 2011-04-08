//
//  BlioFlowView.m
//  BlioApp
//
//  Created by James Montgomerie on 04/01/2010.
//  Copyright 2010 Things Made Out Of Other Things. All rights reserved.
//

#import "SCHFlowView.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"
#import "KNFBTextFlowParagraphSource.h"
#import <libEucalyptus/EucBookView.h>
//#import "BlioFlowPaginateOperation.h"
//#import "BlioFlowEucBook.h"
//#import "BlioBookManager.h"
//#import "BlioBookmark.h"
//#import "BlioParagraphSource.h"
//#import "BlioBUpeBook.h"
//#import "levenshtein_distance.h"

#import <libEucalyptus/EucBUpeBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/THPair.h>
//#import "NSArray+BlioAdditions.h"

@interface SCHFlowView ()

@property (nonatomic, retain) SCHFlowEucBook *eucBook;
@property (nonatomic, retain) KNFBTextFlowParagraphSource *paragraphSource;
@property (nonatomic, retain) EucBookView *eucBookView;

@end

@implementation SCHFlowView

@synthesize eucBook;
@synthesize paragraphSource;
@synthesize eucBookView;

- (void)initialiseView
{
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    
    eucBook = [[bookManager checkOutEucBookForBookIdentifier:self.isbn] retain];
    paragraphSource = [[bookManager checkOutParagraphSourceForBookIdentifier:self.isbn] retain];
    
    if((eucBookView = [[EucBookView alloc] initWithFrame:self.bounds book:eucBook])) {
        eucBookView.delegate = self;
        //eucBookView.allowsSelection = YES;
        //eucBookView.selectorDelegate = self;
        eucBookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        eucBookView.vibratesOnInvalidTurn = NO;
        [eucBookView setPageTexture:[UIImage imageNamed: @"paper-white.png"] isDark:NO];
        
        [eucBookView addObserver:[self superview] forKeyPath:@"pageCount" options:NSKeyValueObservingOptionInitial context:NULL];
        [eucBookView addObserver:[self superview] forKeyPath:@"pageNumber" options:NSKeyValueObservingOptionInitial context:NULL];
            
        [self addSubview:eucBookView];
    }
}

- (void)dealloc
{
    [eucBookView removeObserver:[self superview] forKeyPath:@"pageCount"];
    [eucBookView removeObserver:[self superview] forKeyPath:@"pageNumber"];
    [eucBookView release], eucBookView = nil;
    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    
    if(paragraphSource) {
        [paragraphSource release], paragraphSource = nil;
        [bookManager checkInParagraphSourceForBookIdentifier:self.isbn];   
    }
    
    if(eucBook) {
        [eucBook release], eucBook = nil;
        [bookManager checkInEucBookForBookIdentifier:self.isbn];  
    }

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isbn:(NSString *)isbn
{
    self = [super initWithFrame:frame isbn:isbn];
    if (self) {        
        [self initialiseView];
    }
    return self;
}

- (void) jumpToPage: (NSInteger) page animated: (BOOL) animated
{
    NSLog(@"Flow view: jumping to page %d", page);
    [eucBookView goToPageNumber:page animated:animated];
}


@end