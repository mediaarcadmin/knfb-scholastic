//
//  SCHReadingView.h
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libEucalyptus/EucSelector.h>

@class SCHReadingView;
@class SCHBookPoint;
@class SCHXPSProvider;
@class SCHTextFlow;

@protocol SCHReadingViewDelegate <NSObject>

@required

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex;
- (void)readingView:(SCHReadingView *)readingView hasMovedToProgressPositionInBook:(CGFloat)progress;

- (void)toggleToolbars;
- (void)hideToolbars;

@end

@interface SCHReadingView : UIView <EucSelectorDelegate> {
    
}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, assign) id <SCHReadingViewDelegate> delegate;
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, retain) SCHTextFlow *textFlow;

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn;

// Overridden methods
// FIXME: change these to a protocol

- (SCHBookPoint *)currentBookPoint;

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated;

- (void)jumpToNextZoomBlock;
- (void)jumpToPreviousZoomBlock;

- (void)didEnterSmartZoomMode;
- (void)didExitSmartZoomMode;

- (void)setFontPointIndex:(NSUInteger)index;
- (NSInteger)maximumFontIndex;
- (NSInteger)pageCount;

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark;

- (NSUInteger)pageIndexForBookPoint:(SCHBookPoint *)bookPoint;
- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex;
- (NSString *)displayPageNumberForPageAtIndex:(NSUInteger)pageIndex;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end