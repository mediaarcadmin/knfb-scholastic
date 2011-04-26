//
//  BITScrubberView.h
//  XPSRenderer
//
//  Created by Gordon Christie on 24/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark BITScrubberViewDelegate
@class SCHScrubberView;
@protocol BITScrubberViewDelegate <NSObject>

@optional
- (void) scrubberView: (SCHScrubberView *) scrubberView beginScrubbingWithValue: (float) currentValue;
- (void) scrubberView: (SCHScrubberView *) scrubberView scrubberValueUpdated: (float) currentValue;
- (void) scrubberView: (SCHScrubberView *) scrubberView endScrubbingWithValue: (float) currentValue;

@end


typedef enum {
	kBITScrubberScrubSpeedNormal = 0,
	kBITScrubberScrubSpeedHalf,
	kBITScrubberScrubSpeedQuarter,
	kBITScrubberScrubSpeedFine	
} BITScrubberScrubSpeed;



#pragma mark -
#pragma mark BITScrubberView

@interface SCHScrubberView : UIView {

}

@property (nonatomic, assign) id <BITScrubberViewDelegate> delegate;

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic, getter=isContinuous) BOOL continuous;
@property (nonatomic, retain) UIImage *currentThumbImage;
@property (readonly) BITScrubberScrubSpeed scrubSpeed;

@end