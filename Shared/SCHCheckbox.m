//
//  SCHCheckbox.m
//  Scholastic
//
//  Created by Neil Gall on 25/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHCheckbox.h"

@interface SCHCheckbox ()
- (void)setupControl;
@end

@implementation SCHCheckbox

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupControl];
    }
    return self;
}

- (void)setupControl
{
    self.userInteractionEnabled = YES;
    [self addTarget:self action:@selector(handleTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:self.selected ? @"checkmark-on" : @"checkmark-off"];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, CGAffineTransformMakeScale(1, -1));
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(0, -height));
    
    // centre the image
    CGSize imageSize = image.size;
    CGRect drawRect = CGRectMake(floorf((width-imageSize.width)/2), floorf((height-imageSize.height)/2), imageSize.width, imageSize.height);
    CGContextDrawImage(context, drawRect, [image CGImage]);
}

- (void)handleTap:(id)sender
{
    self.selected = !self.selected;
}

@end
