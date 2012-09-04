//
//  SCHBSBReplacedNavigateImageElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedNavigateImageElement.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBReplacedNavigateImageElement()

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *targetNode;
@property (nonatomic, retain) UIView *navigateView;

@end

@implementation SCHBSBReplacedNavigateImageElement

@synthesize image;
@synthesize targetNode;
@synthesize navigateView;

- (void)dealloc
{
    [image release], image = nil;
    [targetNode release], targetNode = nil;
    [navigateView release], navigateView = nil;
    [super dealloc];
}

- (id)initWithImage:(UIImage *)navigateImage targetNode:(NSString *)navigateTarget;
{
    if (self = [super initWithPointSize:10]) {
        image = [navigateImage retain];
        targetNode = [navigateTarget copy];
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

- (void)renderInRect:(CGRect)rect inContext:(CGContextRef)context
{
    // noop
}

- (void)navigateToNode:(id)sender
{
    [self.delegate navigateToNode:self.targetNode fromNode:self.nodeId];
}

@end
