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
@class SCHBookRange;
@class SCHXPSProvider;
@class SCHTextFlow;
@class SCHBookIdentifier;
@class EucSelector;
@class EucSelectorRange;

typedef enum 
{
	SCHReadingViewSelectionModeYoungerDictionary = 0,
	SCHReadingViewSelectionModeOlderDictionary,
    SCHReadingViewSelectionModeHighlights
} SCHReadingViewSelectionMode;

@protocol SCHReadingViewDelegate <NSObject>

@required


- (UIColor *)highlightColor;
- (NSArray *)highlightsForLayoutPage:(NSUInteger)page;

- (void)addHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
- (void)deleteHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;

- (void)readingViewWillBeginTurning:(SCHReadingView *)readingView;
- (void)readingViewWillBeginUserInitiatedZooming:(SCHReadingView *)readingView;

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex;
- (void)readingView:(SCHReadingView *)readingView hasMovedToPageIndicesInRange:(NSRange)pageIndicesRange withFocusedPageIndex:(NSUInteger)pageIndex;
- (void)readingView:(SCHReadingView *)readingView hasMovedToProgressPositionInBook:(CGFloat)progress;

- (void)readingView:(SCHReadingView *)readingView hasSelectedWordForSpeaking:(NSString *)word;
- (void)requestDictionaryForWord:(NSString *)word mode:(SCHReadingViewSelectionMode) mode;

- (void)hideToolbars;

@end

@interface SCHReadingView : UIView <EucSelectorDelegate> {
    
}

@property (nonatomic, readonly) id <SCHReadingViewDelegate> delegate;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, retain) SCHTextFlow *textFlow;
@property (nonatomic, assign) SCHReadingViewSelectionMode selectionMode;
@property (nonatomic, retain, readonly) EucSelector *selector;

- (id)initWithFrame:(CGRect)frame 
     bookIdentifier:(SCHBookIdentifier *)bookIdentifier 
managedObjectContext:(NSManagedObjectContext *)managedObjectContext 
           delegate:(id<SCHReadingViewDelegate>)delegate
              point:(SCHBookPoint *)point;

// Overridden methods
// FIXME: change these to a protocol

- (SCHBookPoint *)currentBookPoint;
- (SCHBookPoint *)currentBookPointIgnoringMultipleDisplayPages:(BOOL)ignoreMultipleDisplayPages;
- (SCHBookRange *)currentBookRange;

- (void)currentLayoutPage:(NSUInteger *)layoutPage pageWordOffset:(NSUInteger *)pageWordOffset;

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated;
- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;

- (void)setFontPointIndex:(NSUInteger)index;
- (NSInteger)maximumFontIndex;
- (NSInteger)pageCount;

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark;

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint;
- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex;

- (void)layoutPage:(NSUInteger *)layoutPage 
    pageWordOffset:(NSUInteger *)pageWordOffset 
      forBookPoint:(SCHBookPoint *)bookPoint
    includingFolioBlocks:(BOOL)folio;

- (SCHBookPoint *)bookPointForLayoutPage:(NSUInteger)layoutPage 
                          pageWordOffset:(NSUInteger)pageWordOffset
                    includingFolioBlocks:(BOOL)folio;

- (NSArray *)highlightRangesForCurrentPage;
- (NSArray *)highlightsForLayoutPage:(NSUInteger)page;
- (void)addHighlightWithSelection:(EucSelectorRange *)selectorRange;
- (void)deleteHighlightWithSelection:(EucSelectorRange *)selectorRange;
- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index;
- (void)refreshPageTurningViewImmediately:(BOOL)immediately;

- (void)attachSelector;
- (void)detachSelector;
- (void)configureSelectorForSelectionMode;
- (void)dismissSelector;

- (void)unhandledTapAtPoint:(CGPoint)point;

- (EucSelectorRange *)selectorRangeFromBookRange:(SCHBookRange *)range;
- (NSArray *)bookRangesFromSelectorRange:(EucSelectorRange *)selectorRange;
- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange;
- (void)dismissFollowAlongHighlighter;
- (void)followAlongHighlightWordAtPoint:(SCHBookPoint *)bookPoint withCompletionHandler:(dispatch_block_t)completion;
- (void)followAlongHighlightWordForLayoutPage:(NSUInteger)layoutPage pageWordOffset:(NSUInteger)pageWordOffset withCompletionHandler:(dispatch_block_t)completion;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (UIImage *)pageSnapshot;
- (void)dismissReadingViewAdornments;

- (CGRect) pageRect;

@end