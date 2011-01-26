//
//  BWKScrubberView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 24/01/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark BWKScrubberViewDelegate
@class BWKScrubberView;
@protocol BWKScrubberViewDelegate <NSObject>

@optional
- (void) scrubberView: (BWKScrubberView *) scrubberView beginScrubbingWithValue: (float) currentValue;
- (void) scrubberView: (BWKScrubberView *) scrubberView scrubberValueUpdated: (float) currentValue;
- (void) scrubberView: (BWKScrubberView *) scrubberView endScrubbingWithValue: (float) currentValue;

@end


@interface BWKScrubberView : UIView {

}

@property (nonatomic, assign) id <BWKScrubberViewDelegate> delegate;

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic, getter=isContinuous) BOOL continuous;

@end