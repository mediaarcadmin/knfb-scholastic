//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kProfileViewCellButtonWidthPad = 141.0f;
static const CGFloat kProfileViewCellButtonWidthPhone = 136.0f;
static const CGFloat kProfileViewCellButtonEdgePad = 124.0f;
static const CGFloat kProfileViewCellButtonEdgePhone = 10.0f;

@interface SCHProfileViewCell ()

@property (nonatomic, retain) UIButton *leftCellButton;
@property (nonatomic, retain) NSIndexPath *leftIndexPath;
@property (nonatomic, retain) UIButton *centerCellButton;
@property (nonatomic, retain) NSIndexPath *centerIndexPath;
@property (nonatomic, retain) UIButton *rightCellButton;
@property (nonatomic, retain) NSIndexPath *rightIndexPath;
@property (nonatomic, assign) CGSize buttonImageSize;
@property (nonatomic, assign) SCHProfileCellLayoutStyle cellStyle;

- (UIButton *)addButtonWithBackground:(UIImage *)backgroundImage;

@end

@implementation SCHProfileViewCell

@synthesize leftCellButton;
@synthesize leftIndexPath;
@synthesize centerCellButton;
@synthesize centerIndexPath;
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
        UIImage *buttonBackgroundImage = [UIImage imageNamed:@"sm_bttn_blue_UNselected_3part"];
        buttonImageSize = [buttonBackgroundImage size];
        leftCellButton = [[self addButtonWithBackground:buttonBackgroundImage] retain];
        [self.contentView addSubview:leftCellButton];
        centerCellButton = [[self addButtonWithBackground:buttonBackgroundImage] retain];
        [self.contentView addSubview:centerCellButton];
        rightCellButton = [[self addButtonWithBackground:buttonBackgroundImage] retain];         
        [self.contentView addSubview:rightCellButton];
    }
    return self;
}

- (void)dealloc
{
    [leftCellButton release], leftCellButton = nil;
    [leftIndexPath release], leftIndexPath = nil;    
    [centerCellButton release], centerCellButton = nil;
    [centerIndexPath release], centerIndexPath = nil;
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
    
    cellButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cellButton.titleLabel.minimumFontSize = 10;
    cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    cellButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    return cellButton;
}

- (void)setButtonTitles:(NSArray *)buttonTitles forIndexPaths:(NSArray *)indexPaths forCellStyle:(SCHProfileCellLayoutStyle)aStyle
{
    self.cellStyle = aStyle;
    
    [self.leftCellButton setTitle:([buttonTitles count] > 0 ? [buttonTitles objectAtIndex:0] : nil) forState:UIControlStateNormal];
    self.leftIndexPath = ([indexPaths count] > 0 ? [indexPaths objectAtIndex:0] : nil);
    
    [self.centerCellButton setTitle:([buttonTitles count] > 1 ? [buttonTitles objectAtIndex:1] : nil) forState:UIControlStateNormal];
    self.centerIndexPath = ([indexPaths count] > 1 ? [indexPaths objectAtIndex:1] : nil);
    
    [self.rightCellButton setTitle:([buttonTitles count] > 2 ? [buttonTitles objectAtIndex:2] : nil) forState:UIControlStateNormal];
    self.rightIndexPath = ([indexPaths count] > 2 ? [indexPaths objectAtIndex:2] : nil);
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
        width = kProfileViewCellButtonWidthPhone;
    }
    
    switch (self.cellStyle) {
        case kSCHProfileCellLayoutStyle1Up: {
            [self.leftCellButton setFrame:CGRectMake(CGRectGetMinX(contentRect) + ceilf((CGRectGetWidth(contentRect) - width) / 2.0f), 
                                                     ceilf((CGRectGetHeight(contentRect) - imageSize.height) / 2.0f), 
                                                     width, 
                                                     imageSize.height)];
            [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];        
            
            self.centerCellButton.hidden = YES;
            self.rightCellButton.hidden = YES;
        } break;
        case kSCHProfileCellLayoutStyle2Up: {
            CGRect leftButtonRect = contentRect;
            leftButtonRect.size.width /= 2.0;
            CGRect centerButtonRect = contentRect;
            centerButtonRect.size.width /= 2.0;
            centerButtonRect.origin.x += centerButtonRect.size.width;    
            
            CGFloat edge;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                edge = kProfileViewCellButtonEdgePad;
            } else {
                edge = kProfileViewCellButtonEdgePhone;
            }
            
            [self.leftCellButton setFrame:CGRectMake(ceilf((CGRectGetWidth(self.frame) - 2 * width - 1 * edge)/2.0f),
                                                     ceilf((CGRectGetHeight(leftButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                                     width, 
                                                     self.buttonImageSize.height)];
            [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];    
            
              
            [self.centerCellButton setFrame:CGRectMake(CGRectGetMaxX(leftCellButton.frame) + edge,
                                                      ceilf((CGRectGetHeight(centerButtonRect) - self.buttonImageSize.height) / 2.0f), 
                                                      width, 
                                                      self.buttonImageSize.height)];
            [self.centerCellButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            
            self.centerCellButton.hidden = NO;
            self.rightCellButton.hidden = YES;
        } break;
        case kSCHProfileCellLayoutStyle3Up: {
            CGRect leftButtonRect = contentRect;
            leftButtonRect.size.width /= 3.0;
            CGRect centerButtonRect = contentRect;
            centerButtonRect.size.width /= 3.0;
            centerButtonRect.origin.x += centerButtonRect.size.width;
            CGRect rightButtonRect = contentRect;
            rightButtonRect.size.width /= 3.0;
            rightButtonRect.origin.x += CGRectGetMaxX(centerButtonRect);
            
            CGFloat edge;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                edge = kProfileViewCellButtonEdgePad;
            } else {
                edge = kProfileViewCellButtonEdgePhone;
            }
            
            [self.leftCellButton setFrame:CGRectMake(ceilf((CGRectGetWidth(self.frame) - 3 * width - 2 * edge)/2.0f),
                                                     ceilf((CGRectGetHeight(leftButtonRect) - self.buttonImageSize.height) / 2.0f),
                                                     width,
                                                     self.buttonImageSize.height)];
            [self.leftCellButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            
            
            [self.centerCellButton setFrame:CGRectMake(CGRectGetMaxX(leftCellButton.frame) + edge,
                                                       ceilf((CGRectGetHeight(centerButtonRect) - self.buttonImageSize.height) / 2.0f),
                                                       width,
                                                       self.buttonImageSize.height)];
            [self.centerCellButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            
            [self.rightCellButton setFrame:CGRectMake(CGRectGetMaxX(centerCellButton.frame) + edge,
                                                       ceilf((CGRectGetHeight(rightButtonRect) - self.buttonImageSize.height) / 2.0f),
                                                       width,
                                                       self.buttonImageSize.height)];
            [self.rightCellButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
            
            self.centerCellButton.hidden = NO;
            self.rightCellButton.hidden = NO;
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
    } else if (sender == self.centerCellButton) {
        [self.delegate profileViewCell:self 
               didSelectButtonAnimated:YES
                             indexPath:self.centerIndexPath];
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
