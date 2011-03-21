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
@class BITScrubberView;
@protocol BITScrubberViewDelegate <NSObject>

@optional
- (void) scrubberView: (BITScrubberView *) scrubberView beginScrubbingWithValue: (float) currentValue;
- (void) scrubberView: (BITScrubberView *) scrubberView scrubberValueUpdated: (float) currentValue;
- (void) scrubberView: (BITScrubberView *) scrubberView endScrubbingWithValue: (float) currentValue;

@end


typedef enum {
	kBITScrubberScrubSpeedNormal = 0,
	kBITScrubberScrubSpeedHalf,
	kBITScrubberScrubSpeedQuarter,
	kBITScrubberScrubSpeedFine	
} BITScrubberScrubSpeed;



#pragma mark -
#pragma mark BITScrubberView

@interface BITScrubberView : UIView {

}

@property (nonatomic, assign) id <BITScrubberViewDelegate> delegate;

@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float value;
@property (nonatomic, getter=isContinuous) BOOL continuous;
@property (nonatomic, retain) UIImage *currentThumbImage;
@property (readonly) BITScrubberScrubSpeed scrubSpeed;

@end