//
//  SCHTourStepContainerView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepContainerView.h"
#import "TTTAttributedLabel.h"

#define HEIGHT_WITHOUT_TITLE_IPAD 412
#define HEIGHT_WITH_TITLE_IPAD 379
#define HEIGHT_WITHOUT_TITLE_IPHONE 260
#define HEIGHT_WITH_TITLE_IPHONE 230

@interface SCHTourStepContainerView ()

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) TTTAttributedLabel *subtitleLabel;

@property (nonatomic, retain) UIView *topContainer;
@property (nonatomic, retain) UIView *bottomContainer;
@end

@implementation SCHTourStepContainerView

@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize containerTitleText;
@synthesize containerSubtitleText;
@synthesize mainTourStepView;
@synthesize secondTourStepView;
@synthesize topContainer;
@synthesize bottomContainer;

- (void)dealloc
{
    [titleLabel release], titleLabel = nil;
    [subtitleLabel release], subtitleLabel = nil;
    [containerTitleText release], containerTitleText = nil;
    [containerSubtitleText release], containerSubtitleText = nil;
    [mainTourStepView release], mainTourStepView = nil;
    [secondTourStepView release], secondTourStepView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat topInset = floorf(frame.size.height * 0.01);
        CGFloat totalHeight = floorf(frame.size.height * 0.98);
        CGRect topContainerFrame = CGRectZero;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            topInset = floorf(frame.size.height * 0.03);
            totalHeight = floorf(frame.size.height * 0.97);
            topContainerFrame = CGRectMake(0, topInset, frame.size.width, floorf(totalHeight * 0.24) - floorf(topInset / 2));
        } else {
            topContainerFrame = CGRectMake(0, topInset, frame.size.width, floorf(totalHeight * 0.17) - floorf(topInset / 2));
        }
        

        
        self.topContainer = [[[UIView alloc] initWithFrame:topContainerFrame] autorelease];
        
        self.topContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.bottomContainer = [[[UIView alloc] initWithFrame:
                                 CGRectMake(0, self.topContainer.frame.origin.y + self.topContainer.frame.size.height,
                                            frame.size.width, totalHeight - self.topContainer.frame.size.height)]
                                            autorelease];
        
        self.bottomContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [self addSubview:self.topContainer];
        [self addSubview:self.bottomContainer];
        
        
        // Initialization code
        
        CGFloat titleLabelHeight = floorf(self.topContainer.frame.size.height * 0.6);
        CGFloat subtitleLabelHeight = floorf(self.topContainer.frame.size.height * 0.4);
        CGFloat labelInset = floorf(frame.size.width * 0.035);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            labelInset = 5;
        }
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:
                            CGRectMake(labelInset * 2, 0,
                                       (frame.size.width - (labelInset * 4)), titleLabelHeight)]
                           autorelease];
        
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:38];
        } else {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        }
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;

        [self.topContainer addSubview:self.titleLabel];
        
        self.subtitleLabel = [[[TTTAttributedLabel alloc] initWithFrame:
                            CGRectMake(floorf(labelInset * 4), titleLabelHeight,
                                       (frame.size.width - floorf(labelInset * 8)), subtitleLabelHeight)]
                           autorelease];
        
        self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.subtitleLabel.backgroundColor = [UIColor clearColor];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.subtitleLabel.font = [UIFont systemFontOfSize:13];
        } else {
            self.subtitleLabel.font = [UIFont systemFontOfSize:11];
        }
        self.subtitleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textAlignment = UITextAlignmentCenter;
        self.subtitleLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;

        [self.topContainer addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)layoutForCurrentTourStepViews
{
    if (self.mainTourStepView && !self.secondTourStepView) {
        // one view only
        
        NSLog(@"Laying out single view.");
        
        BOOL iPhoneLayout = NO;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            iPhoneLayout = YES;
        }
        
        [self.mainTourStepView removeFromSuperview];
        
        if (self.mainTourStepView.stepHeaderTitle && [self.mainTourStepView.stepHeaderTitle length] > 0) {
            if (iPhoneLayout) {
                self.mainTourStepView.frame = CGRectMake(0, 0, 280, HEIGHT_WITH_TITLE_IPHONE);
            } else {
                self.mainTourStepView.frame = CGRectMake(0, 0, 555, HEIGHT_WITH_TITLE_IPAD);
            }
        } else {
            if (iPhoneLayout){
                self.mainTourStepView.frame = CGRectMake(0, 0, 280, HEIGHT_WITHOUT_TITLE_IPHONE);
            } else {
                self.mainTourStepView.frame = CGRectMake(0, 0, 555, HEIGHT_WITHOUT_TITLE_IPAD);
            }
        }
        
        CGFloat topOffset = 0;
        
        if (iPhoneLayout && self.mainTourStepView.stepHeaderTitle && [self.mainTourStepView.stepHeaderTitle length] > 0) {
            topOffset = 15;
        }
        
        self.mainTourStepView.center = CGPointMake(self.bottomContainer.frame.size.width / 2,
                                                   (self.bottomContainer.frame.size.height / 2) + topOffset);
        self.mainTourStepView.frame = CGRectIntegral(self.mainTourStepView.frame);
        
        [self.bottomContainer addSubview:self.mainTourStepView];
        
    } else {
        // two views
        NSLog(@"Laying out two views.");
        
        [self.mainTourStepView removeFromSuperview];
        
        if (self.mainTourStepView.stepHeaderTitle && [self.mainTourStepView.stepHeaderTitle length] > 0) {
            self.mainTourStepView.frame = CGRectMake(0, 0, 450, HEIGHT_WITH_TITLE_IPAD);
        } else {
            self.mainTourStepView.frame = CGRectMake(0, 0, 450, HEIGHT_WITHOUT_TITLE_IPAD);
        }

        self.mainTourStepView.center = CGPointMake(self.bottomContainer.frame.size.width / 4,
                                                   self.bottomContainer.frame.size.height / 2);
        self.mainTourStepView.frame = CGRectIntegral(self.mainTourStepView.frame);
        
        [self.bottomContainer addSubview:self.mainTourStepView];
        
        if (self.secondTourStepView.stepHeaderTitle && [self.secondTourStepView.stepHeaderTitle length] > 0) {
            self.secondTourStepView.frame = CGRectMake(0, 0, 450, HEIGHT_WITH_TITLE_IPAD);
        } else {
            self.secondTourStepView.frame = CGRectMake(0, 0, 450, HEIGHT_WITHOUT_TITLE_IPAD);
        }
        
        self.secondTourStepView.center = CGPointMake((self.bottomContainer.frame.size.width / 4) * 3,
                                                   self.bottomContainer.frame.size.height / 2);
        self.secondTourStepView.frame = CGRectIntegral(self.secondTourStepView.frame);
        
        [self.bottomContainer addSubview:self.secondTourStepView];
    }
    
    // lay out the header text
    CGSize requiredTitleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                                constrainedToSize:CGSizeMake(self.titleLabel.frame.size.width, CGFLOAT_MAX)
                                                    lineBreakMode:UILineBreakModeWordWrap];
    
    CGSize requiredSubtitleSize = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font
                                                constrainedToSize:CGSizeMake(self.subtitleLabel.frame.size.width, CGFLOAT_MAX)
                                                    lineBreakMode:UILineBreakModeWordWrap];
    
    
    
    CGRect titleRect = self.titleLabel.frame;
    titleRect.size.height = requiredTitleSize.height;
    self.titleLabel.frame = titleRect;
    
    CGRect subtitleRect = self.subtitleLabel.frame;
    subtitleRect.origin.y = titleRect.origin.y + titleRect.size.height + 5;
    subtitleRect.size.height = requiredSubtitleSize.height;
    self.subtitleLabel.frame = subtitleRect;
}


- (NSString *)containerTitleText
{
    if (self.titleLabel) {
        return self.titleLabel.text;
    }
    
    return nil;
}

- (NSString *)containerSubtitleText
{
    if (self.subtitleLabel) {
        return self.subtitleLabel.text;
    }
    
    return nil;
}

- (void)setContainerTitleText:(NSString *)newContainerTitleText
{
    if (self.titleLabel) {
        self.titleLabel.text = newContainerTitleText;
    }
}

- (void)setContainerSubtitleText:(NSString *)newContainerSubtitleText
{
    if (self.subtitleLabel) {
        self.subtitleLabel.text = newContainerSubtitleText;
    }
}

- (void)setMainTourStepView:(SCHTourStepView *)newMainTourStepView
{
    SCHTourStepView *oldTourStepView = mainTourStepView;
    mainTourStepView = [newMainTourStepView retain];
    [oldTourStepView release];
    
    self.mainTourStepView.delegate = self;
}

- (void)setSecondTourStepView:(SCHTourStepView *)newSecondTourStepView
{
    SCHTourStepView *oldTourStepView = secondTourStepView;
    secondTourStepView = [newSecondTourStepView retain];
    [oldTourStepView release];
    
    self.secondTourStepView.delegate = self;
}

- (void)tourStepPressedButton:(SCHTourStepView *)tourStepView
{
    if (tourStepView == self.mainTourStepView) {
        [self.delegate tourStepContainer:self pressedButtonAtIndex:0];
    } else if (tourStepView == self.secondTourStepView) {
        [self.delegate tourStepContainer:self pressedButtonAtIndex:1];
    } else {
        NSLog(@"Warning: got a button press on an unrecognised tour view.");
    }
}

@end
