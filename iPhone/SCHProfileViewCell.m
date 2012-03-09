//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kProfileViewCellButtonWidthPad = 296.0f;
static const CGFloat kProfileViewCellButtonWidthPhone1Up = 280.0f;
static const CGFloat kProfileViewCellButtonWidthPhone2Up = 226.0f;
static const CGFloat kProfileViewCellButtonEdgePad = 10.0f;
static const CGFloat kProfileViewCellButtonEdgePhone = 5.0f;

@interface SCHProfileViewCell ()

@property (nonatomic, retain) UIButton *leftCellButton;
@property (nonatomic, retain) NSIndexPath *leftIndexPath;
@property (nonatomic, retain) UIButton *rightCellButton;
@property (nonatomic, retain) NSIndexPath *rightIndexPath;
@property (nonatomic, assign) CGSize buttonImageSize;
@property (nonatomic, assign) SCHProfileCellLayoutStyle cellStyle;

- (UIButton *)addButtonWithBackground:(UIImage *)backgroundImage;

@end

@implementation SCHProfileViewCell

@synthesize leftCellButton;
@synthesize leftIndexPath;
@synthesize rightCellButton;
@synthesize rightIndexPath;
@synthesize buttonImageSize;
@synthesize delegate;
@synthesize cellStyle;

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

- (void)setButtonTitles:(NSArray *)buttonTitles forIndexPaths:(NSArray *)indexPaths forCellStyle:(SCHProfileCellLayoutStyle)aStyle
{
    self.cellStyle = aStyle;
    
    [self.leftCellButton setTitle:([buttonTitles count] > 0 ? [buttonTitles objectAtIndex:0] : nil) forState:UIControlStateNormal];
    self.leftIndexPath = ([indexPaths count] > 0 ? [indexPaths objectAtIndex:0] : nil);
    
    [self.rightCellButton setTitle:([buttonTitles count] > 1 ? [buttonTitles objectAtIndex:1] : nil) forState:UIControlStateNormal];
    self.rightIndexPath = ([indexPaths count] > 1 ? [indexPaths objectAtIndex:1] : nil);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width;
    CGRect contentRect = self.contentView.bounds;
    CGSize imageSize = self.buttonImageSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = kProfileViewCellButtonWidthPad;
    } else {
        switch (self.cellStyle) {
            case kSCHProfileCellLayoutStyle1Up:          
                width = kProfileViewCellButtonWidthPhone1Up;
            break;
            case kSCHProfileCellLayoutStyle2UpSideBySide: 
            case kSCHProfileCellLayoutStyle2UpCentered:
                width = kProfileViewCellButtonWidthPhone2Up;
                break;
        }
    }
    
    switch (self.cellStyle) {
        case kSCHProfileCellLayoutStyle1Up:
        case kSCHProfileCellLayoutStyle2UpCentered: {
            [self.leftCellButton setFrame:CGRectMake(CGRectGetMinX(contentRect) + ceilf((CGRectGetWidth(contentRect) - width) / 2.0f), 
                                                     ceilf((CGRectGetHeight(contentRect) - imageSize.height) / 2.0f), 
                                                     width, 
                                                     imageSize.height)];
            [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];        
            
            self.rightCellButton.hidden = YES;
        } break;
        case kSCHProfileCellLayoutStyle2UpSideBySide: {
            CGRect leftButtonRect = contentRect;
            leftButtonRect.size.width /= 2.0;
            CGRect rightButtonRect = contentRect;
            rightButtonRect.size.width /= 2.0;
            rightButtonRect.origin.x += rightButtonRect.size.width;    
            
            CGFloat edge;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                edge = kProfileViewCellButtonEdgePad;
            } else {
                edge = kProfileViewCellButtonEdgePhone;
            }
            
            [self.leftCellButton setFrame:CGRectMake(CGRectGetMaxX(leftButtonRect) - width - edge, 
                                                     ceilf((CGRectGetHeight(leftButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                                     width, 
                                                     self.buttonImageSize.height)];
            [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];    
            
            self.rightCellButton.hidden = NO;    
            [self.rightCellButton setFrame:CGRectMake(CGRectGetMinX(rightButtonRect) + edge,
                                                      ceilf((CGRectGetHeight(rightButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                                      width, 
                                                      self.buttonImageSize.height)];
            [self.rightCellButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        } break;
    }
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
