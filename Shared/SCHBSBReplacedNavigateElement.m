//
//  SCHBSBReplacedNavigateElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedNavigateElement.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBReplacedNavigateElement()

@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) UIView *navigateView;
@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation SCHBSBReplacedNavigateElement

@synthesize label;
@synthesize action;
@synthesize navigateView;
@synthesize fontSize;

- (void)dealloc
{
    [label release], label = nil;
    [action release], action = nil;
    [navigateView release], navigateView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point label:(NSArray *)navigateLabel action:(NSString *)navigateAction;
{
    if (self = [super initWithPointSize:point]) {
        label = [navigateLabel copy];
        action = [navigateAction copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    CGFloat adjustedSize;
    
    CGSize textSize = [self.label sizeWithFont:[UIFont fontWithName:@"Times New Roman" size:self.pointSize] minFontSize:6 actualFontSize:&adjustedSize forWidth:160 lineBreakMode:UILineBreakModeWordWrap];
    
    textSize.width += 20;
    textSize.height += 20;
    
    return textSize;
}

- (THCGViewSpiritElement *)newViewSpiritElement
{
    if (self.navigateView) {
        return [[EucUIViewViewSpiritElement alloc] initWithView:self.navigateView];
    }
    
    return nil;
}

- (UIView *)navigateView
{
    if (!navigateView) {
        CGRect frame = CGRectZero;
        frame.size = self.intrinsicSize;
        
        UIButton *button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        button.frame = frame;
        [button.titleLabel setFont:[UIFont fontWithName:@"Times New Roman" size:self.pointSize]];
        [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [button.titleLabel setMinimumFontSize:6];
        [button.titleLabel setNumberOfLines:0];
        [button.titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [button.titleLabel setTextAlignment:UITextAlignmentCenter];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:self.label forState:UIControlStateNormal];
        [button addTarget:nil action:NSSelectorFromString(self.action) forControlEvents:UIControlEventTouchUpInside];
        
        navigateView = button;
    }
    
    return navigateView;
}

- (void)renderInRect:(CGRect)rect inContext:(CGContextRef)context
{
    // noop
}

@end
