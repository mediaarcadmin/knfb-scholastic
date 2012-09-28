//
//  SCHTourStepView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHTourStepView.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHTourStepView ()

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) UIButton *actionButton;

@end

@implementation SCHTourStepView

@synthesize delegate;
@synthesize contentView;
@synthesize actionButton;
@synthesize bottomView;

- (void)dealloc
{
    delegate = nil;
    [contentView release], contentView = nil;
    [actionButton release], actionButton = nil;
    [bottomView release], bottomView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // frame is going to be total size, minus a 33 pixel high white bar
        
        CGRect mainRect = frame;
        mainRect.size.height -= 33;
        
        self.bottomView = [[[UIView alloc] initWithFrame:CGRectMake(0, mainRect.size.height, frame.size.width, 33)] autorelease];
        self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.bottomView.backgroundColor = [UIColor whiteColor];
        
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.actionButton.frame = CGRectMake(mainRect.size.width - 100, -20, 120, 53);
        self.actionButton.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 20);
        self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [self.actionButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13]];
        [self.actionButton.titleLabel setTextColor:[UIColor whiteColor]];
        
        UIImage *stretchedBackImage = [[UIImage imageNamed:@"greytourbutton"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        
        [self.actionButton setBackgroundImage:stretchedBackImage forState:UIControlStateNormal];
        
        // FIXME: styling
        [self.actionButton addTarget:self action:@selector(performButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.bottomView addSubview:self.actionButton];
        [self addSubview:self.bottomView];
        
        self.contentView = [[UIView alloc] initWithFrame:mainRect];
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.contentView.layer.cornerRadius = 5;
        
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.contentView.layer.borderWidth = 1;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        self.layer.cornerRadius = 5;
        
        self.backgroundColor = [UIColor blackColor];
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 1;
        
        [self addSubview:self.contentView];
        
        self.clipsToBounds = YES;
        
        
        // action button
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
        [self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}


@end
