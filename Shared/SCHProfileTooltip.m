//
//  SCHProfileTooltip.m
//  Scholastic
//
//  Created by Gordon Christie on 08/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHProfileTooltip.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"

#define TEXT_X_INSET 25
#define TEXT_Y_INSET 10
#define TITLE_SUBTITLE_GAP 2

@interface SCHProfileTooltip ()

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIButton *closeButton;

@property (nonatomic, retain) UIView *topTextContainerView;
@property (nonatomic, retain) UIView *bottomTextContainerView;
@property (nonatomic, retain) UIView *insetContainerView;

@property (nonatomic, retain) TTTAttributedLabel *titleLabel;
@property (nonatomic, retain) TTTAttributedLabel *subtitleLabel;
@property (nonatomic, retain) TTTAttributedLabel *secondTitleLabel;
@property (nonatomic, retain) TTTAttributedLabel *secondSubtitleLabel;


@end

@implementation SCHProfileTooltip

@synthesize delegate;
@synthesize backgroundImageView;
@synthesize closeButton;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize secondTitleLabel;
@synthesize secondSubtitleLabel;
@synthesize topTextContainerView;
@synthesize bottomTextContainerView;
@synthesize insetContainerView;

- (void)dealloc
{
    delegate = nil;
    [insetContainerView release], insetContainerView = nil;
    [backgroundImageView release], backgroundImageView = nil;
    [closeButton release], closeButton = nil;
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [secondTitleLabel release], secondTitleLabel = nil;
    [secondSubtitleLabel release], secondSubtitleLabel = nil;
    [topTextContainerView release], topTextContainerView = nil;
    [bottomTextContainerView release], bottomTextContainerView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    return self;
}

- (id)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)insets
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // background image
        self.backgroundImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.backgroundImageView.contentMode = UIViewContentModeCenter;
        
        [self addSubview:self.backgroundImageView];

        // inset calculation view
        self.insetContainerView = [[[UIView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, frame.size.width, frame.size.height), TEXT_X_INSET, TEXT_Y_INSET)] autorelease];
        
        CGRect insetContainerFrame = self.insetContainerView.frame;
        insetContainerFrame.origin.x = insetContainerFrame.origin.x + insets.left;
        insetContainerFrame.size.width = insetContainerFrame.size.width - insets.left - insets.right;
        insetContainerFrame.origin.y = insetContainerFrame.origin.y + insets.top;
        insetContainerFrame.size.height = insetContainerFrame.size.height - insets.top - insets.bottom;
        self.insetContainerView.frame = insetContainerFrame;
        
        self.insetContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGFloat totalHeight = insetContainerView.frame.size.height;
        CGFloat totalWidth = insetContainerView.frame.size.width;
        

        CGRect topTextContainerFrame = CGRectMake(0, 0, totalWidth, floorf(totalHeight / 2));
        
        self.topTextContainerView = [[[UIView alloc] initWithFrame:topTextContainerFrame] autorelease];
        self.topTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        CGRect bottomTextContainerFrame = CGRectMake(0, topTextContainerFrame.origin.y + topTextContainerFrame.size.height, totalWidth, topTextContainerFrame.size.height);
        
        self.bottomTextContainerView = [[[UIView alloc] initWithFrame:bottomTextContainerFrame] autorelease];
        self.bottomTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        
        self.titleLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.topTextContainerView.frame.size.width, floorf(self.topTextContainerView.frame.size.height * 0.33) - (TITLE_SUBTITLE_GAP / 2))] autorelease];
        self.titleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.titleLabel.textAlignment = UITextAlignmentCenter;
            self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        } else {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        }
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.titleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;
        
        
        
        self.subtitleLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height + TITLE_SUBTITLE_GAP, self.topTextContainerView.frame.size.width, floorf(self.topTextContainerView.frame.size.height - self.titleLabel.frame.size.height))] autorelease];
        self.subtitleLabel.textColor = [UIColor darkGrayColor];
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.subtitleLabel.textAlignment = UITextAlignmentCenter;
            self.subtitleLabel.font = [UIFont systemFontOfSize:12];
        } else {
            self.subtitleLabel.font = [UIFont systemFontOfSize:13];
        }

        self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.subtitleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;

        
        [self.topTextContainerView addSubview:self.titleLabel];
        [self.topTextContainerView addSubview:self.subtitleLabel];
        

        self.secondTitleLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.bottomTextContainerView.frame.size.width, floorf(self.bottomTextContainerView.frame.size.height * 0.33) - (TITLE_SUBTITLE_GAP/2))] autorelease];
        self.secondTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.secondTitleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.secondTitleLabel.backgroundColor = [UIColor clearColor];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.secondTitleLabel.textAlignment = UITextAlignmentCenter;
        }

        self.secondTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.secondTitleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentBottom;

        
        self.secondSubtitleLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, self.secondTitleLabel.frame.size.height + TITLE_SUBTITLE_GAP, self.bottomTextContainerView.frame.size.width, floorf(self.bottomTextContainerView.frame.size.height - self.secondTitleLabel.frame.size.height))] autorelease];
        self.secondSubtitleLabel.textColor = [UIColor darkGrayColor];
        self.secondSubtitleLabel.font = [UIFont systemFontOfSize:12];
        self.secondSubtitleLabel.backgroundColor = [UIColor clearColor];
        self.secondSubtitleLabel.numberOfLines = 0;
        self.secondSubtitleLabel.lineBreakMode = UILineBreakModeWordWrap;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.secondSubtitleLabel.textAlignment = UITextAlignmentCenter;
        }

        self.secondSubtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.secondSubtitleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        
        [self.bottomTextContainerView addSubview:self.secondTitleLabel];
        [self.bottomTextContainerView addSubview:self.secondSubtitleLabel];
        
        
        [self.insetContainerView addSubview:self.topTextContainerView];
        [self.insetContainerView addSubview:self.bottomTextContainerView];
        
        [self addSubview:self.insetContainerView];
        
        // close button
        self.closeButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)] autorelease];
        [self.closeButton setImage:[UIImage imageNamed:@"TooltipCloseButton"] forState:UIControlStateNormal];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
            self.closeButton.center = CGPointMake(self.frame.size.width - (self.closeButton.frame.size.width / 2) - 5,
                                                  self.backgroundImageView.frame.origin.y + floorf(TEXT_Y_INSET / 2));
        } else {
            self.closeButton.center = CGPointMake(self.backgroundImageView.frame.origin.x + self.backgroundImageView.frame.size.width - 10, self.backgroundImageView.frame.origin.y + floorf(TEXT_Y_INSET / 2));
        }
        
//        if (self.closeButton.center.x > self.frame.size.width - (self.closeButton.frame.size.width / 2)) {
//            self.closeButton.center = CGPointMake(floorf(self.frame.size.width - (self.closeButton.frame.size.width / 2)), self.closeButton.center.y);
//        }
        
        self.closeButton.frame = CGRectIntegral(self.closeButton.frame);
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.closeButton];
        

        self.closeButton.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        self.closeButton.layer.shadowOffset = CGSizeMake(2, 2);
        self.closeButton.layer.shadowRadius = 1.0f;
        self.closeButton.layer.shadowOpacity = 0.6;

        
        self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOpacity = 0.6;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

        
//        self.titleLabel.layer.borderColor = [UIColor orangeColor].CGColor;
//        self.titleLabel.layer.borderWidth = 1;
//        self.subtitleLabel.layer.borderColor = [UIColor greenColor].CGColor;
//        self.subtitleLabel.layer.borderWidth = 1;
//        
//        self.secondSubtitleLabel.layer.borderColor = [UIColor purpleColor].CGColor;
//        self.secondSubtitleLabel.layer.borderWidth = 1;
//        self.secondTitleLabel.layer.borderColor = [UIColor blueColor].CGColor;
//        self.secondTitleLabel.layer.borderWidth = 1;
        

//        self.topTextContainerView.layer.borderColor = [UIColor purpleColor].CGColor;
//        self.topTextContainerView.layer.borderWidth = 1;
//        self.bottomTextContainerView.layer.borderColor = [UIColor greenColor].CGColor;
//        self.bottomTextContainerView.layer.borderWidth = 1;
        
        
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (self.backgroundImageView) {
        self.backgroundImageView.image = backgroundImage;
    }
}

- (UIImage *)backgroundImage
{
    if (self.backgroundImageView) {
        return self.backgroundImageView.image;
    }
    
    return nil;
}

- (void)setUsesCloseButton:(BOOL)closeButtonVisible
{
    if (self.closeButton) {
        self.closeButton.hidden = !closeButtonVisible;
    } else {
        self.closeButton.hidden = YES;
    }
}

- (BOOL)usesCloseButton
{
    if (self.closeButton) {
        return !self.closeButton.hidden;
    }
    
    return NO;
}

- (void)setTitle:(NSString *)title bodyText:(NSString *)bodyText
{
    self.titleLabel.text = title;
    self.subtitleLabel.text = bodyText;
    
    self.bottomTextContainerView.hidden = YES;
    
    // set the top label to fill the entire view
    CGRect topFrame = self.topTextContainerView.frame;
    topFrame.size.height = self.insetContainerView.frame.size.height;
    self.topTextContainerView.frame = topFrame;
    
}
- (void)setFirstTitle:(NSString *)title firstBodyText:(NSString *)bodyText secondTitle:(NSString *)secondTitle secondBodyText:(NSString *)secondBodyText
{
    self.titleLabel.text = title;
    self.subtitleLabel.text = bodyText;
    self.secondTitleLabel.text = secondTitle;
    self.secondSubtitleLabel.text = secondBodyText;
    
    self.bottomTextContainerView.hidden = NO;
    
    // set the top label to fill half the view
    CGRect topFrame = self.topTextContainerView.frame;
    topFrame.size.height = floorf(self.insetContainerView.frame.size.height / 2);
    self.topTextContainerView.frame = topFrame;
}


- (void)pressedCloseButton:(UIButton *)button
{
    if (self.delegate) {
        [self.delegate profileTooltipPressedClose:self];
    }
}

@end
