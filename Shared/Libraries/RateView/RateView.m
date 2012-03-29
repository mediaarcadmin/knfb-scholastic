//
//  RateView.m
//  CustomView
//
//  Created by Ray Wenderlich on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RateView.h"

@implementation RateView

@synthesize notSelectedImage;
@synthesize halfSelectedImage;
@synthesize fullSelectedImage;
@synthesize rating;
@synthesize editable;
@synthesize imageViews;
@synthesize maxRating;
@synthesize midMargin;
@synthesize leftMargin;
@synthesize minImageSize;
@synthesize delegate;

- (void)dealloc
{
    [imageViews release], imageViews = nil;
    [notSelectedImage release], notSelectedImage = nil;
    [halfSelectedImage release], halfSelectedImage = nil;
    [fullSelectedImage release], fullSelectedImage = nil;
    [super dealloc];
}

- (void)baseInit {
    self.notSelectedImage = nil;
    self.halfSelectedImage = nil;
    self.fullSelectedImage = nil;
    self.rating = 0;
    self.editable = NO;    
    self.imageViews = [NSMutableArray array];
    self.maxRating = 5;
    self.midMargin = 5;
    self.leftMargin = 0;
    self.minImageSize = CGSizeMake(5, 5);
    self.delegate = nil;    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInit];
    }
    return self;
}

- (void)refresh {
    for(int i = 0; i < self.imageViews.count; ++i) {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        if (self.rating >= i+1) {
            imageView.image = self.fullSelectedImage;
        } else if (self.rating > i) {
            imageView.image = self.halfSelectedImage;
        } else {
            imageView.image = self.notSelectedImage;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.notSelectedImage == nil) return;
    
    float desiredImageWidth = (self.frame.size.width - (self.leftMargin*2) - (self.midMargin*self.imageViews.count)) / self.imageViews.count;
    float imageWidth = MAX(self.minImageSize.width, desiredImageWidth);
    float imageHeight = MAX(self.minImageSize.height, self.frame.size.height);
    
    for (int i = 0; i < self.imageViews.count; ++i) {
        
        UIImageView *imageView = [self.imageViews objectAtIndex:i];
        CGRect imageFrame = CGRectMake(self.leftMargin + i*(self.midMargin+imageWidth), 0, imageWidth, imageHeight);
        imageView.frame = imageFrame;
        
    }    
    
}

- (void)setMaxRating:(int)newMaxRating {
    maxRating = newMaxRating;
    
    // Remove old image views
    for(int i = 0; i < self.imageViews.count; ++i) {
        UIImageView *imageView = (UIImageView *) [self.imageViews objectAtIndex:i];
        [imageView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
    
    // Add new image views
    for(int i = 0; i < maxRating; ++i) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [self.imageViews addObject:imageView];
        [self addSubview:imageView];
        [imageView release], imageView = nil;
    }
    
    // Relayout and refresh
    [self setNeedsLayout];
    [self refresh];
}

- (void)setNotSelectedImage:(UIImage *)image {
    
    UIImage *oldImage = notSelectedImage;
    notSelectedImage = [image retain];
    [oldImage release];
    
    [self refresh];
}

- (void)setHalfSelectedImage:(UIImage *)image {
    UIImage *oldImage = halfSelectedImage;
    halfSelectedImage = [image retain];
    [oldImage release];
    
    [self refresh];
}

- (void)setFullSelectedImage:(UIImage *)image {
    UIImage *oldImage = fullSelectedImage;
    fullSelectedImage = [image retain];
    [oldImage release];
    
    [self refresh];
}

- (void)setRating:(float)newRating {
    rating = newRating;
    [self refresh];
}

- (void)handleTouchAtLocation:(CGPoint)touchLocation {
    if (!self.editable) return;
    
    int newRating = 0;
    for(int i = self.imageViews.count - 1; i >= 0; i--) {
        UIImageView *imageView = [self.imageViews objectAtIndex:i];        
        if (touchLocation.x > imageView.frame.origin.x) {
            newRating = i+1;
            break;
        }
    }
    
    self.rating = newRating;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate rateView:self ratingDidChange:self.rating];
}

@end
