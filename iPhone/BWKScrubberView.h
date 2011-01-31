//
//  BWKScrubberView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 24/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
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


typedef enum {
	kBWKScrubberScrubSpeedNormal = 0,
	kBWKScrubberScrubSpeedHalf,
	kBWKScrubberScrubSpeedQuarter,
	kBWKScrubberScrubSpeedFine	
} BWKScrubberScrubSpeed;



#pragma mark -
#pragma mark BWKScrubberView

@interface BWKScrubberView : UIView {

}

@property (nonatomic, assign) id <BWKScrubberViewDelegate> delegate;

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic, getter=isContinuous) BOOL continuous;
@property (nonatomic, retain) UIImage *currentThumbImage;
@property (readonly) BWKScrubberScrubSpeed scrubSpeed;

@end