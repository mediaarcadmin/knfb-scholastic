//
//  BITScrubberView.m
//  XPSRenderer
//
//  Created by Gordon Christie on 24/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHScrubberView.h"

#pragma mark -
#pragma mark Class Extension

@interface SCHScrubberView()

- (void) initValues;

@property (nonatomic) float currentMultiplier;
@property (nonatomic) float currentPercentage;
@property (nonatomic, retain) UIImage *defaultThumbImage;
@property (readwrite) BITScrubberScrubSpeed scrubSpeed;

@end

#pragma mark -
#pragma mark BITScrubberView implementation

#define TRACK_DOT_WIDTH 2

@implementation SCHScrubberView

@synthesize delegate;
@synthesize minimumValue;
@synthesize maximumValue;
@synthesize value;
@synthesize continuous;
@synthesize currentThumbImage;
@synthesize scrubSpeed;

@synthesize currentMultiplier;
@synthesize currentPercentage;
@synthesize defaultThumbImage;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		[self initValues];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		[self initValues];
    }
    return self;
	
}

- (void) initValues
{
	// Initialise with useful defaults
	self.continuous = YES;
	self.minimumValue = 1.0f;
	self.maximumValue = 100.0f;
	self.value = 50.0f;
	self.currentMultiplier = 1.0f;
	
	self.defaultThumbImage = [UIImage imageNamed:@"thumbImage.png"];
	
	self.contentMode = UIViewContentModeRedraw; 

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touches began!");
	
	if (delegate && [delegate respondsToSelector:@selector(scrubberView:beginScrubbingWithValue:)]) {
		[delegate scrubberView:self beginScrubbingWithValue:self.value];
	}
	
}
	
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 1) {
		int oldValue = self.value;
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		//NSLog(@"Touch: %@", NSStringFromCGPoint([touch locationInView:self]));
		
		//NSLog(@"Diff: %f", [touch locationInView:self].x - [touch previousLocationInView:self].x);

		
		int yDistance = 0;
		
		if ([touch locationInView:self].y < (self.frame.size.height / 2)) {
			yDistance = ([touch locationInView:self].y * -1) + (self.frame.size.height / 2);
		} else {
			yDistance = ([touch locationInView:self].y) - (self.frame.size.height / 2);
		}
		
		if (yDistance < 40) {
			self.currentMultiplier = 1.0f;
			self.scrubSpeed = kBITScrubberScrubSpeedNormal;
		} else if (yDistance < 80) {
			self.currentMultiplier = 0.5f;
			self.scrubSpeed = kBITScrubberScrubSpeedHalf;
		} else if (yDistance < 120) {
			self.currentMultiplier = 0.25f;
			self.scrubSpeed = kBITScrubberScrubSpeedQuarter;
		} else {
			self.currentMultiplier = 0.1f;
			self.scrubSpeed = kBITScrubberScrubSpeedFine;
		}
		
		if (self.currentMultiplier == 1.0f) {
			float currentX = [touch locationInView:self].x;
			if (currentX < 0) {
				currentX = 0;
			} else if (currentX > self.frame.size.width) {
				currentX = self.frame.size.width;
			}
			
			
			self.currentPercentage = currentX / self.frame.size.width;
			//NSLog(@"percent: %f multiplier: %f", self.currentPercentage, self.currentMultiplier);
		} else {
			float percentageChange = ([touch locationInView:self].x - [touch previousLocationInView:self].x) / self.frame.size.width;
			
			percentageChange = percentageChange * self.currentMultiplier;
			
			self.currentPercentage += percentageChange;
		}		
		
		if (self.currentPercentage < 0) {
			self.currentPercentage = 0;
		}
		
		if (self.currentPercentage > 1) {
			self.currentPercentage = 1;
		}
		
		// uses ivar directly to avoid resetting the percentage
		value = self.minimumValue + ((self.maximumValue - self.minimumValue) * currentPercentage);
//		NSLog(@"Current value: %f percentage: %f", self.value, self.currentPercentage);

		if (self.continuous && delegate && [delegate respondsToSelector:@selector(scrubberView:scrubberValueUpdated:)]) {
			[delegate scrubberView:self scrubberValueUpdated:self.value];
		}
		
		if (oldValue != (int) self.value) {
			[self setNeedsDisplay];
		}
		
	}

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touches ended.");

	if (delegate && [delegate respondsToSelector:@selector(scrubberView:endScrubbingWithValue:)]) {
		[delegate scrubberView:self endScrubbingWithValue:self.value];
	}
}

- (void) setValue:(float) newValue
{
//	NSLog(@"Current percentage (before setValue): %f", self.currentPercentage);
	value = newValue;
	
	float diff = value - self.minimumValue;
	float range = self.maximumValue - self.minimumValue;
	self.currentPercentage = diff/range;
	
//	NSLog(@"Current percentage (after setValue): %f", self.currentPercentage);
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
	
	// get the current thumb image, then get the width
	UIImage *thumbImage = nil;
	float currentThumbWidth = 0;
	
	thumbImage = self.currentThumbImage;
	
	if (!thumbImage) {
		thumbImage = self.defaultThumbImage;
	}
	
	if (thumbImage) {
		currentThumbWidth = thumbImage.size.width;
	} 
	
	float pixelRange = (self.maximumValue - self.minimumValue);
	
//	NSLog(@"Rect width: %f, range: %f", CGRectGetWidth(rect), pixelRange);
	if (CGRectGetWidth(rect) <= (pixelRange * TRACK_DOT_WIDTH)) {
		CGContextSetRGBFillColor(ctx, 0.65f, 0.65f, 0.65f, 0.7f);
		CGContextFillRect(ctx, CGRectMake(currentThumbWidth / 2, (CGRectGetHeight(rect)/2) - 2, CGRectGetWidth(rect) - currentThumbWidth, 4));
	} else {
		// draw dots
		float dotGap = (CGRectGetWidth(rect) - (pixelRange * TRACK_DOT_WIDTH)) / pixelRange;
//		NSLog(@"dot gap: %f", dotGap);

		int i = 0;
		for (float f = (currentThumbWidth / 2); f < CGRectGetWidth(rect) - (currentThumbWidth / 2); f += dotGap) {
			
			if (i == 9) { 
				CGContextSetRGBFillColor(ctx, 0.930f, 0.653f, 0.321f, 0.9f);
				i = 0;
			} else {
				CGContextSetRGBFillColor(ctx, 0.65f, 0.65f, 0.65f, 0.7f);
				i++;
			}
			CGContextFillRect(ctx, CGRectMake(f, (CGRectGetHeight(rect)/2) - 2, TRACK_DOT_WIDTH, 4));
		}
	}
	
	
	//float minThumbX = 0;
	float maxThumbX = CGRectGetWidth(rect) - currentThumbWidth;
	
	float currentThumbX = maxThumbX * currentPercentage;
	
	CGContextDrawImage(ctx, CGRectMake(currentThumbX, 7, currentThumbWidth, CGRectGetHeight(rect) - 14), thumbImage.CGImage);
}


- (void)dealloc {
	[defaultThumbImage release], defaultThumbImage = nil;
    [super dealloc];
}


@end
