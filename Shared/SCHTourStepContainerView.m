//
//  SCHTourStepContainerView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepContainerView.h"

@interface SCHTourStepContainerView ()

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;

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
        
        CGFloat topInset = floorf(frame.size.height * 0.05);
        CGFloat totalHeight = floorf(frame.size.height * 0.9);
        
        
        self.topContainer = [[[UIView alloc] initWithFrame:
                              CGRectMake(0, topInset,
                                         frame.size.width, floorf(totalHeight * 0.25) - floorf(topInset / 2))]
                             autorelease];
        
        self.topContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.bottomContainer = [[[UIView alloc] initWithFrame:
                                 CGRectMake(0, self.topContainer.frame.origin.y + self.topContainer.frame.size.height,
                                            frame.size.width, totalHeight - self.topContainer.frame.size.height)]
                                            autorelease];
        
        self.bottomContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
//        self.topContainer.layer.borderColor = [UIColor purpleColor].CGColor;
//        self.topContainer.layer.borderWidth = 1;
//        self.bottomContainer.layer.borderColor = [UIColor orangeColor].CGColor;
//        self.bottomContainer.layer.borderWidth = 1;
//        self.layer.borderColor = [UIColor greenColor].CGColor;
//        self.layer.borderWidth = 1;

        
        [self addSubview:self.topContainer];
        [self addSubview:self.bottomContainer];
        
        
        // Initialization code
        
        CGFloat titleLabelHeight = floorf(self.topContainer.frame.size.height * 0.4);
        CGFloat subtitleLabelHeight = floorf(self.topContainer.frame.size.height * 0.6);
        CGFloat labelInset = floorf(frame.size.width * 0.1);
        
        self.titleLabel = [[[UILabel alloc] initWithFrame:
                            CGRectMake(labelInset, 0,
                                       (frame.size.width - 2 * labelInset), titleLabelHeight)]
                           autorelease];
        
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:38];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = UITextAlignmentCenter;

        [self.topContainer addSubview:self.titleLabel];
        
        self.subtitleLabel = [[[UILabel alloc] initWithFrame:
                            CGRectMake(labelInset * 2, titleLabelHeight,
                                       (frame.size.width - (labelInset * 4)), subtitleLabelHeight)]
                           autorelease];
        
        self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        self.subtitleLabel.backgroundColor = [UIColor clearColor];

        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.textColor = [UIColor colorWithRed:0.082 green:0.388 blue:0.596 alpha:1];
        self.subtitleLabel.numberOfLines = 0;
        self.subtitleLabel.textAlignment = UITextAlignmentCenter;
        
//        self.subtitleLabel.layer.borderColor = [UIColor purpleColor].CGColor;
//        self.subtitleLabel.layer.borderWidth = 1;
//        self.titleLabel.layer.borderColor = [UIColor purpleColor].CGColor;
//        self.titleLabel.layer.borderWidth = 1;
        

        [self.topContainer addSubview:self.subtitleLabel];
        
    }
    return self;
}

- (void)layoutForCurrentTourStepViews
{
    // FIXME: this needs to handle the case where there are two views
    
    if (self.mainTourStepView && !self.secondTourStepView) {
        // one view only
        
        NSLog(@"Laying out single view.");
        
        self.mainTourStepView.frame = CGRectMake(0, 0, 555, 412);
        self.mainTourStepView.center = CGPointMake(self.bottomContainer.frame.size.width / 2,
                                                   self.bottomContainer.frame.size.height / 2);
        self.mainTourStepView.frame = CGRectIntegral(self.mainTourStepView.frame);
        
        [self.bottomContainer addSubview:self.mainTourStepView];
        
    } else {
        // two views
    }
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



@end
