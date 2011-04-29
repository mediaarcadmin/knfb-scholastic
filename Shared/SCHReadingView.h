//
//  SCHReadingView.h
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHReadingView;
@class SCHBookPoint;
@class SCHXPSProvider;
@class SCHTextFlow;

typedef enum {
	SCHReadingViewPaperTypeBlack = 0,
	SCHReadingViewPaperTypeWhite,
	SCHReadingViewPaperTypeSepia
} SCHReadingViewPaperType;

@protocol SCHReadingViewDelegate <NSObject>

@optional

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex;
- (void)unhandledTouchOnPageForReadingView:(SCHReadingView *)readingView;

@end

@interface SCHReadingView : UIView {
    
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, retain) id <SCHReadingViewDelegate> delegate;
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, retain) SCHTextFlow *textFlow;

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn;

// Overridden methods
// FIXME: change these to a protocol

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)jumpToNextZoomBlock;
- (void)jumpToPreviousZoomBlock;

- (void)didEnterSmartZoomMode;
- (void)didExitSmartZoomMode;

- (void) setPaperType: (SCHReadingViewPaperType) type;
- (void) setFontPointIndex: (NSInteger) index;
- (NSInteger) maximumFontIndex;
- (NSInteger) pageCount;

- (NSUInteger)pageIndexForBookPoint:(SCHBookPoint *)bookPoint;
- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex;
- (NSString *)displayPageNumberForPageAtIndex:(NSUInteger)pageIndex;

- (void)goToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated;

@end