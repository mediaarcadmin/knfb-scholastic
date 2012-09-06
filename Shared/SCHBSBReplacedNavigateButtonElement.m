//
//  SCHBSBReplacedNavigateElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 21/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedNavigateButtonElement.h"
#import "SCHBSBReplacedElementNavigateButton.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import <libEucalyptus/EucCSSDPI.h>

@interface SCHBSBReplacedNavigateButtonElement()

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *targetNode;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIView *navigateView;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, retain) UIImage *image;

@end

@implementation SCHBSBReplacedNavigateButtonElement

@synthesize label;
@synthesize targetNode;
@synthesize binding;
@synthesize value;
@synthesize navigateView;
@synthesize fontSize;
@synthesize image;

- (void)dealloc
{
    [label release], label = nil;
    [targetNode release], targetNode = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [navigateView release], navigateView = nil;
    [image release], image = nil;
    
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
    
    textSize.width += 6 + self.image.size.width;
    textSize.height += 6;
    
    textSize.height = MAX(textSize.height, self.image.size.width);
    
    return textSize;
}

- (THCGViewSpiritElement *)newViewSpiritElement
{
    if (self.navigateView) {
        return [[EucUIViewViewSpiritElement alloc] initWithView:self.navigateView];
    }
    
    return nil;
}

- (UIImage *)image
{
    if (!image) {
        image = [[UIImage imageNamed:@"button-go"] retain];
    }
    
    return image;
}

- (UIView *)navigateView
{
    if (!navigateView) {
        CGRect frame = CGRectZero;
        frame.size = self.intrinsicSize;
        
        UIView *container = [[UIView alloc] initWithFrame:frame];
        container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        container.autoresizesSubviews = YES;
        
        CGRect buttonFrame = CGRectMake(frame.size.width - frame.size.height, 0, frame.size.height, frame.size.height);
        CGRect labelFrame =  CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height);
        
        SCHBSBReplacedElementNavigateButton *button = [[[SCHBSBReplacedElementNavigateButton alloc] initWithFrame:buttonFrame] autorelease];
        [button addTarget:self action:@selector(navigateToNode:) forControlEvents:UIControlEventTouchUpInside];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];

        [container addSubview:button];
        
        UILabel *buttonLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
        [buttonLabel setFont:[UIFont fontWithName:@"Times New Roman" size:self.pointSize]];
        [buttonLabel setAdjustsFontSizeToFitWidth:YES];
        [buttonLabel setMinimumFontSize:6];
        [buttonLabel setNumberOfLines:0];
        [buttonLabel setLineBreakMode:UILineBreakModeWordWrap];
        [buttonLabel setTextAlignment:UITextAlignmentLeft];
        [buttonLabel setTextColor:[UIColor blackColor]];
        [buttonLabel setText:self.label];
        [buttonLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
        
        [container addSubview:buttonLabel];
        
        navigateView = container;
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
