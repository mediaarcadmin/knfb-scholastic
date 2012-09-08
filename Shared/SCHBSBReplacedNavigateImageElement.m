//
//  SCHBSBReplacedNavigateImageElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedNavigateImageElement.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import <libEucalyptus/EucCSSDPI.h>

@interface SCHBSBReplacedNavigateImageElement()

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *targetNode;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIView *navigateView;

@end

@implementation SCHBSBReplacedNavigateImageElement

@synthesize image;
@synthesize targetNode;
@synthesize binding;
@synthesize value;
@synthesize navigateView;

- (void)dealloc
{
    [image release], image = nil;
    [targetNode release], targetNode = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [navigateView release], navigateView = nil;
    [super dealloc];
}

- (id)initWithImage:(UIImage *)navigateImage targetNode:(NSString *)navigateTarget binding:(NSString *)aBinding value:(NSString *)aValue
{
    if (self = [super init]) {
        image = [navigateImage retain];
        targetNode = [navigateTarget copy];
        binding = [aBinding copy];
        value = [aValue copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{    
    return self.image.size;
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
        
        UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        button.frame = frame;
        [button setImage:self.image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(navigateToNode:) forControlEvents:UIControlEventTouchUpInside];
        
        navigateView = button;
    }
    
    return navigateView;
}

- (void)navigateToNode:(id)sender
{
    if (self.binding && self.value) {
        [self.delegate binding:self.binding didUpdateValue:self.value];
    }
    
    [self.delegate navigateToNode:self.targetNode fromNode:self.nodeId];
}

@end
