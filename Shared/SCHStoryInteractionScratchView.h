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
@property (nonatomic, assign) BOOL showFullImage;

@end

@protocol SCHStoryInteractionScratchViewDelegate <NSObject>

@optional
- (void)scratchView: (SCHStoryInteractionScratchView *) scratchView uncoveredPoints: (NSInteger) points;

@end
