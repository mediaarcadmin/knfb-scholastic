//
//  BWKScrubberView.m
//  XPSRenderer
//
//  Created by Gordon Christie on 24/01/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import "BWKScrubberView.h"

#pragma mark -
#pragma mark Class Extension

@interface BWKScrubberView()

@property (nonatomic) float currentMultiplier;
@property (nonatomic) float currentPercentage;

@end

#pragma mark -
#pragma mark BWKScrubberView implementation

@implementation BWKScrubberView

@synthesize delegate;
@synthesize minimumValue;
@synthesize maximumValue;
@synthesize value;
@synthesize continuous;

@synthesize currentMultiplier;
@synthesize currentPercentage;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialise with useful defaults
		self.continuous = YES;
		self.minimumValue = 1.0f;
		self.maximumValue = 100.0f;
		self.value = 50.0f;
		self.currentMultiplier = 1.0f;
		self.currentPercentage = 0.5f;
    }
    return self;
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
		UITouch *touch = [[touches allObjects] objectAtIndex:0];
		//NSLog(@"Touch: %@", NSStringFromCGPoint([touch locationInView:self]));
		
		int yDistance = 0;
		
		if ([touch locationInView:self].y < (self.frame.size.height / 2)) {
			yDistance = ([touch locationInView:self].y * -1) + (self.frame.size.height / 2);
		} else {
			yDistance = ([touch locationInView:self].y) - (self.frame.size.height / 2);
		}
		
		if (yDistance < 40) {
			self.currentMultiplier = 1.0f;
		} else if (yDistance < 80) {
			self.currentMultiplier = 0.5f;
		} else if (yDistance < 120) {
			self.currentMultiplier = 0.25f;
		} else {
			self.currentMultiplier = 0.125f;
		}
		
		self.currentPercentage = [touch locationInView:self].x / self.frame.size.width;
		
		self.value = self.minimumValue + ((self.maximumValue - self.minimumValue) * currentPercentage);
		
//		NSLog(@"Current value: %f", self.value);
		
		if (self.continuous && delegate && [delegate respondsToSelector:@selector(scrubberView:scrubberValueUpdated:)]) {
			[delegate scrubberView:self scrubberValueUpdated:self.value];
		}
		
		[self setNeedsDisplay];
	}

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Touches ended.");

	if (delegate && [delegate respondsToSelector:@selector(scrubberView:endScrubbingWithValue:)]) {
		[delegate scrubberView:self endScrubbingWithValue:self.value];
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
	
    //CGContextSetRGBFillColor(ctx, 0.65f, 0.65f, 0.65f, 0.3f);
	//CGContextFillRect(ctx, CGRectMake(self.currentPercentage * CGRectGetWidth(rect) - 5, 0, 10, CGRectGetHeight(rect)));
	
	UIImage *thumbImage = [UIImage imageNamed:@"thumbImage.png"];
	
	CGContextDrawImage(ctx, CGRectMake(self.currentPercentage * CGRectGetWidth(rect) - 10, 2, 20, CGRectGetHeight(rect) - 4), thumbImage.CGImage);
}


- (void)dealloc {
    [super dealloc];
}


@end
