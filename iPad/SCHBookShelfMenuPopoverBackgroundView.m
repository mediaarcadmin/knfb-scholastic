//
//  SCHBookShelfMenuPopoverBackgroundView.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//
//  Based on code from http://www.scianski.com/customizing-uipopover-with-uipopoverbackgroundview/
//  and tutorial code from iOS5 by Tutorials

#import "SCHBookShelfMenuPopoverBackgroundView.h"
#import "SCHThemeManager.h"

// Predefined arrow image width and height
#define ARROW_WIDTH 35.0
#define ARROW_HEIGHT 19.0

// Predefined content insets
#define TOP_CONTENT_INSET 8
#define LEFT_CONTENT_INSET 8
#define BOTTOM_CONTENT_INSET 8
#define RIGHT_CONTENT_INSET 8

#pragma mark - Private interface

@interface SCHBookShelfMenuPopoverBackgroundView ()

@property (nonatomic, retain) UIImage *topArrowImage;
@property (nonatomic, retain) UIImage *leftArrowImage;
@property (nonatomic, retain) UIImage *rightArrowImage;
@property (nonatomic, retain) UIImage *bottomArrowImage;

- (UIImage *)tintImageWithThemeColor:(UIImage *)image;

@end

#pragma mark - Implementation

@implementation SCHBookShelfMenuPopoverBackgroundView

@synthesize topArrowImage;
@synthesize leftArrowImage;
@synthesize rightArrowImage;
@synthesize bottomArrowImage;

@synthesize arrowOffset; 
@synthesize arrowDirection;
@synthesize popoverBackgroundImageView;
@synthesize arrowImageView;

- (void)dealloc
{
    [topArrowImage release], topArrowImage = nil;
    [leftArrowImage release], leftArrowImage = nil;
    [rightArrowImage release], rightArrowImage = nil;
    [bottomArrowImage release], bottomArrowImage = nil;
    
    [arrowImageView release], arrowImageView = nil;
    [popoverBackgroundImageView release], popoverBackgroundImageView = nil;
    [super dealloc];
}

#pragma mark - Overriden class methods

// The width of the arrow triangle at its base.
+ (CGFloat)arrowBase 
{
    return ARROW_WIDTH;
}

// The height of the arrow (measured in points) from its base to its tip.
+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

// The insets for the content portion of the popover.
+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

#pragma mark - Custom setters for updating layout

// Whenever arrow changes direction or position layout subviews will be called in order to update arrow and background frames

-(void) setArrowOffset:(CGFloat)newArrowOffset
{
    arrowOffset = newArrowOffset;
    [self setNeedsLayout];
}

-(void) setArrowDirection:(UIPopoverArrowDirection)newArrowDirection
{
    arrowDirection = newArrowDirection;
    [self setNeedsLayout];
}

#pragma mark - Initialization

-(id)initWithFrame:(CGRect)frame 
{    
    if (self = [super initWithFrame:frame])
    {
        self.topArrowImage = [self tintImageWithThemeColor:[UIImage imageNamed:@"popover-black-top-arrow-image.png"]];
        self.leftArrowImage = [self tintImageWithThemeColor:[UIImage imageNamed:@"popover-black-left-arrow-image.png"]];
        self.bottomArrowImage = [self tintImageWithThemeColor:[UIImage imageNamed:@"popover-black-bottom-arrow-image.png"]];
        self.rightArrowImage = [self tintImageWithThemeColor:[UIImage imageNamed:@"popover-black-right-arrow-image.png"]];
        
        UIImage *popoverBackgroundImage = [[self tintImageWithThemeColor:[UIImage imageNamed:@"popover-black-bcg-image.png"]] resizableImageWithCapInsets:UIEdgeInsetsMake(49, 46, 49, 45)];
        self.popoverBackgroundImageView = [[[UIImageView alloc] initWithImage:popoverBackgroundImage] autorelease];
        [self addSubview:self.popoverBackgroundImageView];
        
        self.arrowImageView = [[[UIImageView alloc] init] autorelease];
        [self addSubview:self.arrowImageView]; 
        
        [self bringSubviewToFront:self.popoverBackgroundImageView];
    }
    
    return self;
}

#pragma mark - Layout subviews

-(void)layoutSubviews
{    
    CGFloat popoverImageOriginX = 0;
    CGFloat popoverImageOriginY = 0;
    
    CGFloat popoverImageWidth = self.bounds.size.width;
    CGFloat popoverImageHeight = self.bounds.size.height;
    
    CGFloat arrowImageOriginX = 0;
    CGFloat arrowImageOriginY = 0;
    
    CGFloat arrowImageWidth = ARROW_WIDTH;
    CGFloat arrowImageHeight = ARROW_HEIGHT;
    
    // Radius value you used to make rounded corners in your popover background image
    CGFloat cornerRadius = 9;
    
    switch (self.arrowDirection) {
            
        case UIPopoverArrowDirectionUp:
            
            popoverImageOriginY = ARROW_HEIGHT - 2;
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT;
            
            // Calculating arrow x position using arrow offset, arrow width and popover width
            arrowImageOriginX = roundf((self.bounds.size.width - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            // If arrow image exceeds rounded corner arrow image x postion is adjusted 
            if (arrowImageOriginX + ARROW_WIDTH > self.bounds.size.width - cornerRadius)
            {
                arrowImageOriginX -= cornerRadius;
            }
            
            if (arrowImageOriginX < cornerRadius)
            {
                arrowImageOriginX += cornerRadius;
            }
            
            // Setting arrow image for current arrow direction
            self.arrowImageView.image = self.topArrowImage;
            
            break; 
            
        case UIPopoverArrowDirectionDown:
            
            popoverImageHeight = self.bounds.size.height - ARROW_HEIGHT + 2;
            
            arrowImageOriginX = roundf((self.bounds.size.width - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginX + ARROW_WIDTH > self.bounds.size.width - cornerRadius)
            {
                arrowImageOriginX -= cornerRadius;
            }
            
            if (arrowImageOriginX < cornerRadius)
            {
                arrowImageOriginX += cornerRadius;
            }
            
            arrowImageOriginY = popoverImageHeight - 2;
            
            self.arrowImageView.image = self.bottomArrowImage;
            
            break;
            
        case UIPopoverArrowDirectionLeft:
            
            popoverImageOriginX = ARROW_HEIGHT - 2;
            popoverImageWidth = self.bounds.size.width - ARROW_HEIGHT;
            
            arrowImageOriginY = roundf((self.bounds.size.height - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginY + ARROW_WIDTH > self.bounds.size.height - cornerRadius)
            {
                arrowImageOriginY -= cornerRadius;
            }
            
            if (arrowImageOriginY < cornerRadius)
            {
                arrowImageOriginY += cornerRadius;
            }
            
            arrowImageWidth = ARROW_HEIGHT;
            arrowImageHeight = ARROW_WIDTH;
            
            self.arrowImageView.image = self.leftArrowImage;
            
            break;
            
        case UIPopoverArrowDirectionRight:
            
            popoverImageWidth = self.bounds.size.width - ARROW_HEIGHT + 2;
            
            arrowImageOriginX = popoverImageWidth - 2;
            arrowImageOriginY = roundf((self.bounds.size.height - ARROW_WIDTH) / 2 + self.arrowOffset);
            
            if (arrowImageOriginY + ARROW_WIDTH > self.bounds.size.height - cornerRadius)
            {
                arrowImageOriginY -= cornerRadius;
            }
            
            if (arrowImageOriginY < cornerRadius)
            {
                arrowImageOriginY += cornerRadius;
            }
            
            arrowImageWidth = ARROW_HEIGHT;
            arrowImageHeight = ARROW_WIDTH;
            
            self.arrowImageView.image = self.rightArrowImage;
            
            break;
            
        default:
            break;
    }
    
    self.popoverBackgroundImageView.frame = CGRectMake(popoverImageOriginX, popoverImageOriginY, popoverImageWidth, popoverImageHeight);
    self.arrowImageView.frame = CGRectMake(arrowImageOriginX, arrowImageOriginY, arrowImageWidth, arrowImageHeight);
}

- (UIImage *)tintImageWithThemeColor:(UIImage *)image
{
    // tint colour comes from the theme manager
    UIColor *tintColor = [[SCHThemeManager sharedThemeManager] colorForPopoverBackground];
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [tintColor setFill];
    
    // translate graphics context
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode then draw the original image
    CGContextSetBlendMode(context, kCGBlendModeSoftLight);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // set a mask that matches the shape of the image, then draw a colored rectangle
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

@end
