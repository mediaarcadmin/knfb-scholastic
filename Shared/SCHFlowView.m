//
//  BlioFlowView.m
//  BlioApp
//
//  Created by James Montgomerie on 04/01/2010.
//  Copyright 2010 Things Made Out Of Other Things. All rights reserved.
//

#import "SCHFlowView.h"
//#import "BlioFlowPaginateOperation.h"
//#import "BlioFlowEucBook.h"
//#import "BlioBookManager.h"
//#import "BlioBookmark.h"
//#import "BlioParagraphSource.h"
//#import "BlioBUpeBook.h"
//#import "levenshtein_distance.h"
#import <libEucalyptus/EucBookView.h>
#import <libEucalyptus/EucBUpeBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/THPair.h>
//#import "NSArray+BlioAdditions.h"

@interface SCHFlowView ()
@end

@implementation SCHFlowView

- (void)initialiseView
{
    //BlioBookManager *bookManager = [BlioBookManager sharedBookManager];
    //_eucBook = [[bookManager checkOutEucBookForBookWithID:bookID] retain];
   // 
    //if(_eucBook) {            
      //  self.paragraphSource = [bookManager checkOutParagraphSourceForBookWithID:bookID];
        
        //if([_eucBook isKindOfClass:[BlioFlowEucBook class]]) {
          //  BlioTextFlow *textFlow = [bookManager checkOutTextFlowForBookWithID:bookID];
            //_textFlowFlowTreeKind = textFlow.flowTreeKind;
            //[bookManager checkInTextFlowForBookWithID:bookID];
        //}            
    EucBookView *_eucBookView;
        if((_eucBookView = [[EucBookView alloc] initWithFrame:self.bounds book:nil])) {
            //_eucBookView.delegate = self;
            //_eucBookView.allowsSelection = YES;
            //_eucBookView.selectorDelegate = self;
            _eucBookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _eucBookView.vibratesOnInvalidTurn = NO;
            
            //if (!animated) {
                //[self goToBookmarkPoint:[bookManager bookWithID:bookID].implicitBookmarkPoint animated:NO saveToHistory:NO];
            //}
            
            //[_eucBookView addObserver:self forKeyPath:@"pageCount" options:NSKeyValueObservingOptionInitial context:NULL];
            //[_eucBookView addObserver:self forKeyPath:@"pageNumber" options:NSKeyValueObservingOptionInitial context:NULL];
            
            [self addSubview:_eucBookView];
        }
        
   // }
}

- (id)initWithFrame:(CGRect)frame book:(id)aBook
{
    self = [super initWithFrame:frame book:aBook];
    if (self) {        
        [self initialiseView];
        
//        if(!_eucBookView) {
//            [self release];
//            self = nil;
//        }
    }
    return self;
}


@end