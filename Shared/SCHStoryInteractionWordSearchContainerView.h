//
//  SCHStoryInteractionWordSearchContainerView.h
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHStoryInteractionWordSearch;
@class SCHStoryInteractionWordSearchContainerView;

@protocol SCHStoryInteractionWordSearchContainerViewDelegate
@required
- (void)letterContainer:(SCHStoryInteractionWordSearchContainerView *)containerView
  didSelectFromStartRow:(NSInteger)startRow
            startColumn:(NSInteger)startColumn
                 extent:(NSInteger)extent
             vertically:(BOOL)vertical;
@end

@interface SCHStoryInteractionWordSearchContainerView : UIView {}

@property (nonatomic, assign) id<SCHStoryInteractionWordSearchContainerViewDelegate> delegate;
@property (nonatomic, assign) NSInteger letterGap;

- (void)populateFromWordSearchModel:(SCHStoryInteractionWordSearch *)wordSearch;
- (void)clearSelection;
- (void)addPermanentHighlightFromStartRow:(NSInteger)startRow
                              startColumn:(NSInteger)startColumn
                                   extent:(NSInteger)extent
                                 vertical:(BOOL)isVertical
                                withColor:(UIColor *)color;

@end
