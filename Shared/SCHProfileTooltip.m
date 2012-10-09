//
//  SCHProfileTooltip.m
//  Scholastic
//
//  Created by Gordon Christie on 08/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHProfileTooltip.h"

@interface SCHProfileTooltip ()

@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIButton *closeButton;

@property (nonatomic, retain) UIView *topTextContainerView;
@property (nonatomic, retain) UIView *bottomTextContainerView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UILabel *secondTitleLabel;
@property (nonatomic, retain) UILabel *secondSubtitleLabel;


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

- (void)dealloc
{
    delegate = nil;
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
    self = [super initWithFrame:frame];
    if (self) {
        // background image
        self.backgroundImageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
        self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.backgroundImageView];
        
        // close button
        self.closeButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)] autorelease];
        [self.closeButton setImage:[UIImage imageNamed:@"TooltipCloseButton"] forState:UIControlStateNormal];
        self.closeButton.center = CGPointMake(frame.origin.x + frame.size.width, frame.origin.y);
        self.closeButton.frame = CGRectIntegral(self.closeButton.frame);
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.closeButton addTarget:self action:@selector(pressedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.closeButton];
        
        // title text
        self.topTextContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, floorf(frame.size.height / 2))] autorelease];
        self.topTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        self.bottomTextContainerView = [[[UIView alloc] initWithFrame:CGRectMake(0, floorf(frame.size.height / 2), frame.size.width, floorf(frame.size.height / 2))] autorelease];
        self.bottomTextContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.topTextContainerView.frame.size.width, floorf(self.topTextContainerView.frame.size.height * 0.33))] autorelease];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

        
        
        self.subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.topTextContainerView.frame.size.width, floorf(self.topTextContainerView.frame.size.height - self.titleLabel.frame.size.height))] autorelease];
        self.subtitleLabel.textColor = [UIColor darkGrayColor];
        self.subtitleLabel.font = [UIFont systemFontOfSize:11];
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;


        [self.topTextContainerView addSubview:self.titleLabel];
        [self.topTextContainerView addSubview:self.subtitleLabel];
        

        self.secondTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bottomTextContainerView.frame.size.width, floorf(self.bottomTextContainerView.frame.size.height * 0.33))] autorelease];
        self.secondTitleLabel.font = [UIFont systemFontOfSize:16];
        self.secondTitleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.secondTitleLabel.backgroundColor = [UIColor clearColor];
        self.secondTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        
        
        self.secondSubtitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, self.secondTitleLabel.frame.size.height, self.bottomTextContainerView.frame.size.width, floorf(self.bottomTextContainerView.frame.size.height - self.secondTitleLabel.frame.size.height))] autorelease];
        self.secondSubtitleLabel.textColor = [UIColor darkGrayColor];
        self.secondSubtitleLabel.font = [UIFont systemFontOfSize:11];
        self.secondSubtitleLabel.backgroundColor = [UIColor clearColor];
        self.secondSubtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

        
        [self.bottomTextContainerView addSubview:self.secondTitleLabel];
        [self.bottomTextContainerView addSubview:self.secondSubtitleLabel];
        
        
        [self addSubview:self.topTextContainerView];
        [self addSubview:self.bottomTextContainerView];
        
        
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
        self.closeButton.hidden = closeButtonVisible;
    }
    
    self.closeButton.hidden = YES;
}

- (BOOL)usesCloseButton
{
    if (self.closeButton) {
        return self.closeButton.hidden;
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
    topFrame.size.height = self.frame.size.height;
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
    topFrame.size.height = floorf(self.frame.size.height / 2);
    self.topTextContainerView.frame = topFrame;
}


- (void)pressedCloseButton:(UIButton *)button
{
    if (self.delegate) {
        [self.delegate profileTooltipPressedClose:self];
    }
}

@end
