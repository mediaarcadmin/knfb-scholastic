//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kProfileViewCellButtonWidth = 296.0f;
static const CGFloat kProfileViewCellButtonEdge = 10.0f;

@interface SCHProfileViewCell ()

@property (nonatomic, retain) UIButton *leftCellButton;
@property (nonatomic, retain) NSIndexPath *leftIndexPath;
@property (nonatomic, retain) UIButton *rightCellButton;
@property (nonatomic, retain) NSIndexPath *rightIndexPath;
@property (nonatomic, assign) CGSize buttonImageSize;
@property (nonatomic, assign) BOOL singleButtonMode;

- (UIButton *)addButtonWithBackground:(UIImage *)backgroundImage;
- (void)setSingleButtonPosition;
- (void)setDoubleButtonPosition;

@end

@implementation SCHProfileViewCell

@synthesize leftCellButton;
@synthesize leftIndexPath;
@synthesize rightCellButton;
@synthesize rightIndexPath;
@synthesize buttonImageSize;
@synthesize delegate;
@synthesize singleButtonMode;

#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage *buttonBackgroundImage = [UIImage imageNamed:@"button-blue"];
        buttonImageSize = [buttonBackgroundImage size];
        leftCellButton = [[self addButtonWithBackground:buttonBackgroundImage] retain];
        [self.contentView addSubview:leftCellButton];        
        rightCellButton = [[self addButtonWithBackground:buttonBackgroundImage] retain];         
        [self.contentView addSubview:rightCellButton];
    }
    return self;
}

- (void)dealloc
{
    [leftCellButton release], leftCellButton = nil;
    [leftIndexPath release], leftIndexPath = nil;    
    [rightCellButton release], rightCellButton = nil;
    [rightIndexPath release], rightIndexPath = nil;
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - Private methods

- (UIButton *)addButtonWithBackground:(UIImage *)backgroundImage
{
    UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cellButton setBackgroundImage:[backgroundImage stretchableImageWithLeftCapWidth:15 topCapHeight:0] 
                          forState:UIControlStateNormal];
    cellButton.backgroundColor = [UIColor clearColor];
    [cellButton addTarget:self 
                   action:@selector(pressed:) 
         forControlEvents:UIControlEventTouchUpInside];
    
    [cellButton addTarget:self 
                   action:@selector(pressedDown:) 
         forControlEvents:UIControlEventTouchDown];
    
    [cellButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cellButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5f] forState:UIControlStateNormal];
    
    cellButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:26.0f];
    cellButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    cellButton.titleLabel.minimumFontSize = 14;
    cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    cellButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    return cellButton;
}

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle 
             leftIndexPath:(NSIndexPath *)aLeftIndexPath
          rightButtonTitle:(NSString *)rightButtonTitle
            rightIndexPath:(NSIndexPath *)aRightIndexPath
{
    [self.leftCellButton setTitle:leftButtonTitle forState:UIControlStateNormal];
    self.leftIndexPath = aLeftIndexPath;
    [self.rightCellButton setTitle:rightButtonTitle forState:UIControlStateNormal];
    self.rightIndexPath = aRightIndexPath;  
    
    self.singleButtonMode = (rightButtonTitle == nil);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.singleButtonMode == YES) {
        [self setSingleButtonPosition];
    } else {
        [self setDoubleButtonPosition];
    }    
}

- (void)setSingleButtonPosition
{
    // the left button == center button
    CGRect centerButtonRect = self.contentView.bounds;
    
    [self.leftCellButton setFrame:CGRectMake(CGRectGetMinX(centerButtonRect) + ceilf((CGRectGetWidth(centerButtonRect) - kProfileViewCellButtonWidth) / 2.0f), 
                                             ceilf((CGRectGetHeight(centerButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                             kProfileViewCellButtonWidth, 
                                             self.buttonImageSize.height)];
    [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];        
    
    self.rightCellButton.hidden = YES;
}

- (void)setDoubleButtonPosition
{
    CGRect leftButtonRect = self.contentView.bounds;
    leftButtonRect.size.width /= 2.0;
    CGRect rightButtonRect = self.contentView.bounds;
    rightButtonRect.size.width /= 2.0;
    rightButtonRect.origin.x += rightButtonRect.size.width;    
    
    [self.leftCellButton setFrame:CGRectMake(CGRectGetMaxX(leftButtonRect) - kProfileViewCellButtonWidth - kProfileViewCellButtonEdge, 
                                             ceilf((CGRectGetHeight(leftButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                             kProfileViewCellButtonWidth, 
                                             self.buttonImageSize.height)];
    [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];    
    
    self.rightCellButton.hidden = NO;    
    [self.rightCellButton setFrame:CGRectMake(CGRectGetMinX(rightButtonRect) + kProfileViewCellButtonEdge,
                                              ceilf((CGRectGetHeight(rightButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                              kProfileViewCellButtonWidth, 
                                              self.buttonImageSize.height)];
    [self.rightCellButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];        
}

#pragma mark - Action methods

- (void)pressed:(id)sender
{
    if (sender == self.leftCellButton) {
        [self.delegate profileViewCell:self 
               didSelectButtonAnimated:YES
                             indexPath:self.leftIndexPath];
    } else if (sender == self.rightCellButton) {
        [self.delegate profileViewCell:self 
               didSelectButtonAnimated:YES
                             indexPath:self.rightIndexPath];        
    }
}

- (void)pressedDown:(id)sender
{
    [CATransaction flush];
}

@end
