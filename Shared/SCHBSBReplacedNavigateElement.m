//
//  SCHBSBReplacedNavigateElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedNavigateElement.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import <libEucalyptus/EucCSSDPI.h>

@interface SCHBSBReplacedNavigateElement()

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *targetNode;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIView *navigateView;
@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation SCHBSBReplacedNavigateElement

@synthesize label;
@synthesize targetNode;
@synthesize binding;
@synthesize value;
@synthesize navigateView;
@synthesize fontSize;

- (void)dealloc
{
    [label release], label = nil;
    [targetNode release], targetNode = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [navigateView release], navigateView = nil;
    [super dealloc];
}

- (id)initWithLabel:(NSString *)navigateLabel targetNode:(NSString *)navigateTarget binding:(NSString *)aBinding value:(NSString *)aValue;
{
    if (self = [super init]) {
        label = [navigateLabel copy];
        targetNode = [navigateTarget copy];
        binding = [aBinding copy];
        value = [aValue copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    CGFloat adjustedSize;
    
    CGSize textSize = [self.label sizeWithFont:[UIFont fontWithName:@"Times New Roman" size:EucCSSPixelsMediumFontSize] minFontSize:6 actualFontSize:&adjustedSize forWidth:160 lineBreakMode:UILineBreakModeWordWrap];
    
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
        [button addTarget:self action:@selector(navigateToNode:) forControlEvents:UIControlEventTouchUpInside];
        
        navigateView = button;
    }
    
    return navigateView;
}

- (void)renderInRect:(CGRect)rect inContext:(CGContextRef)context
{
    // noop
}

- (void)navigateToNode:(id)sender
{
    if (self.binding && self.value) {
        [self.delegate binding:self.binding didUpdateValue:self.value];
    }
    
    [self.delegate navigateToNode:self.targetNode fromNode:self.nodeId];
}

@end
