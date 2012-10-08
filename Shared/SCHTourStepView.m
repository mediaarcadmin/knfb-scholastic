//
//  SCHTourStepView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepView.h"
#import <QuartzCore/QuartzCore.h>

#define STANDARD_CORNER_RADIUS 10

@interface SCHTourStepView ()

@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UILabel *topTitleLabel;

@end

@implementation SCHTourStepView

@synthesize delegate;
@synthesize contentView;
@synthesize actionButton;
@synthesize bottomView;
@synthesize topTitleLabel;

- (void)dealloc
{
    delegate = nil;
    [contentView release], contentView = nil;
    [actionButton release], actionButton = nil;
    [bottomView release], bottomView = nil;
    [topTitleLabel release], topTitleLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // content view size is total size minus 33 pixels for the bottom bar
        CGRect mainRect = frame;
        mainRect.size.height -= 33;
        
        // ** Top title first - it appears above the view to simplify calculation
        self.topTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, -33, frame.size.width, 33)] autorelease];
        self.topTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topTitleLabel.backgroundColor = [UIColor clearColor];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.topTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:21]];
        } else {
            [self.topTitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
        }
        [self.topTitleLabel setTextColor:[UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1]];

        self.topTitleLabel.textAlignment = UITextAlignmentCenter;

        [self addSubview:self.topTitleLabel];

        
        // ** bottom view first - white background, grey action button
        
        self.bottomView = [[[UIView alloc] initWithFrame:CGRectMake(0, mainRect.size.height - 20, frame.size.width, 53)] autorelease];
        self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.bottomView.backgroundColor = [UIColor whiteColor];
        
        self.bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.bottomView.layer.borderWidth = 1;
        self.bottomView.layer.cornerRadius = STANDARD_CORNER_RADIUS;

        // action button
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.actionButton.frame = CGRectMake(mainRect.size.width - 100, 0, 120, 53);
        self.actionButton.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 20);
        self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.actionButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
        } else {
            [self.actionButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]];
        }
        [self.actionButton.titleLabel setTextColor:[UIColor whiteColor]];
        
        UIImage *stretchedBackImage = [[UIImage imageNamed:@"greytourbutton"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        
        [self.actionButton setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(performButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:self.actionButton];
        [self addSubview:self.bottomView];
        
        self.bottomView.hidden = YES;
        
        
        // ** content view
        
        self.contentView = [[UIView alloc] initWithFrame:mainRect];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.contentView.layer.cornerRadius = STANDARD_CORNER_RADIUS;
        
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.borderWidth = 1;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.contentView];
        
        self.contentView.clipsToBounds = YES;
        self.bottomView.clipsToBounds = YES;

        
        self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 0.5;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

        
//        CAShapeLayer* shadowLayer = [CAShapeLayer layer];
//        shadowLayer.frame = [self.contentView bounds];
//        
//        // ** inner shadow for content view
//        shadowLayer.shadowColor = [[UIColor blackColor] CGColor];
//        shadowLayer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//        shadowLayer.shadowOpacity = 0.6f;
//        shadowLayer.shadowRadius = 2;
//        
//        // Causes the inner region in this example to NOT be filled.
//        shadowLayer.fillRule = kCAFillRuleEvenOdd;
//        
//        // Create the larger rectangle path.
//        CGMutablePathRef path = CGPathCreateMutable();
//        CGPathAddRect(path, NULL, CGRectInset(self.contentView.bounds, -42, -42));
//            
//        // Add the inner path so it's subtracted from the outer path.
//        CGPathAddPath(path, NULL, [UIBezierPath bezierPathWithRoundedRect:[shadowLayer bounds]
//                                                         byRoundingCorners:UIRectCornerAllCorners
//                                                               cornerRadii:CGSizeMake(STANDARD_CORNER_RADIUS, STANDARD_CORNER_RADIUS)].CGPath);
//        CGPathCloseSubpath(path);
//        
//        [shadowLayer setPath:path];
//        CGPathRelease(path);
//        
//        [[self.contentView layer] addSublayer:shadowLayer];
//        
//        self.contentView.layer.shouldRasterize = YES;
    }
    return self;
}

- (void)performButtonAction:(UIButton *)button
{
    if (self.delegate) {
        [self.delegate tourStepPressedButton:self];
    }
}

- (NSString *)buttonTitle
{
    if (!self.actionButton) {
        return nil;
    }
    
    return [self.actionButton titleForState:UIControlStateNormal];
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    if (self.actionButton) {
        self.bottomView.hidden = NO;
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        CGRect buttonFrame = self.actionButton.frame;
        CGSize buttonTextSize = [[self.actionButton titleForState:UIControlStateNormal] sizeWithFont:self.actionButton.titleLabel.font];
        
        // FIXME: this is a naive calculation, uses the fixed position of the initial setup to work
        // This should be a more dynamic calculation taking into account the current size of the view
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            buttonFrame.size.width = buttonTextSize.width + 50;
            buttonFrame.origin.x = 1044 - buttonFrame.size.width;
        } else {
            buttonFrame.size.width = buttonTextSize.width + 50;
            buttonFrame.origin.x = 342 - buttonFrame.size.width;
        }
        self.actionButton.frame = buttonFrame;

    }
}

- (NSString *)stepHeaderTitle
{
    if (!self.topTitleLabel) {
        return nil;
    }
    
    return self.topTitleLabel.text;
}


- (void)setStepHeaderTitle:(NSString *)stepHeaderTitle
{
    if (self.topTitleLabel) {
        self.topTitleLabel.text = stepHeaderTitle;
    }
}

@end
