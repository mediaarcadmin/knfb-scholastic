//
//  SCHReadingView.h
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHReadingView;

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

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn;

// Overridden methods

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)jumpToNextZoomBlock;
- (void)jumpToPreviousZoomBlock;

- (void)didEnterSmartZoomMode;
- (void)didExitSmartZoomMode;

- (void) setPaperType: (SCHReadingViewPaperType) type;
- (void) setFontPointIndex: (NSInteger) index;
- (NSInteger) maximumFontIndex;

@end