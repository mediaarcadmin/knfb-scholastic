//
//  SCHImageButton.m
//  Scholastic
//
//  Created by John S. Eddie on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHImageButton.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const kSCHImageButtonCornerRadius = 10.0;
static CGFloat const kSCHImageButtonBorderWidth = 2.0;
static CGFloat const kSCHImageButtonBorderWidthSelected = 4.0;

@interface SCHImageButton ()

- (void)setup;

@end

@implementation SCHImageButton

@synthesize normalColor;
@synthesize selectedColor;
@synthesize selected;
@synthesize actionBlock;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return(self);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)dealloc 
{
    Block_release(actionBlock), actionBlock = nil;

    [super dealloc];
}

- (void)setup
{
    normalColor = [[UIColor colorWithCGColor:self.layer.borderColor] retain];
    selected = NO;
    actionBlock = nil;
    
    self.userInteractionEnabled = YES;
    self.layer.cornerRadius = kSCHImageButtonCornerRadius;  
    self.layer.borderWidth = kSCHImageButtonBorderWidth; 
    self.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                        action:@selector(tapped:)];
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    self.selected = YES;
    if (actionBlock != nil) {
        actionBlock(self);
    }
}

#pragma mark - Accessors

- (void)setNormalColor:(UIColor *)newNormalColor
{
    if (normalColor != newNormalColor) {
        [normalColor release];
        normalColor = [newNormalColor retain];
        if (self.selected == NO) {
            self.layer.borderColor = [self.normalColor CGColor];
        }
    }
}

- (void)setSelected:(BOOL)setSelected
{
    if (selected != setSelected) {
        selected = setSelected;
        if (selected == YES) {
            self.layer.borderWidth = kSCHImageButtonBorderWidthSelected; 
            if (self.selectedColor != nil) {
                self.layer.borderColor = [self.selectedColor CGColor];         
            }
        } else {
            self.layer.borderWidth = kSCHImageButtonBorderWidth; 
            self.layer.borderColor = [self.normalColor CGColor];                 
        }
    }
}

@end
