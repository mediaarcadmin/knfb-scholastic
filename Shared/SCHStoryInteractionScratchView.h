//
//  SCHStoryInteractionScratchView.h
//  Scholastic
//
//  Created by Gordon Christie on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHStoryInteractionScratchViewDelegate;

@interface SCHStoryInteractionScratchView : UIView {
    
}
@property (nonatomic, assign) id <SCHStoryInteractionScratchViewDelegate> delegate;
@property (nonatomic, retain) UIImage *answerImage;
@property (nonatomic, assign) BOOL interactionEnabled;

- (void)setShowFullImage:(BOOL)showFullImage;
- (NSUInteger)uncoveredPointsCount;

@end

@protocol SCHStoryInteractionScratchViewDelegate <NSObject>

@optional
- (void)scratchView: (SCHStoryInteractionScratchView *) scratchView uncoveredPoints: (NSInteger) points;
- (void)scratchViewWasScratched:(SCHStoryInteractionScratchView *)scratchView;
@end
