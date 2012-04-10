//
//  UILabel+ScholasticAdditions.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "UILabel+ScholasticAdditions.h"

@implementation UILabel(ScholasticAdditions)

- (void)adjustPointSizeToFitWidthWithPadding:(CGFloat)padding
{
    CGRect insetBounds = CGRectInset(self.bounds, padding, padding);
    CGFloat fontSize = [self.font pointSize];
    NSString *fontName = [self.font fontName];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    for (; fontSize > 4; fontSize -= 1) {
        font = [UIFont fontWithName:fontName size:fontSize];
        CGSize size = [self.text sizeWithFont:font
                             constrainedToSize:CGSizeMake(CGRectGetWidth(insetBounds), CGFLOAT_MAX)
                                 lineBreakMode:self.lineBreakMode];
        if (size.height <= CGRectGetHeight(insetBounds)) {
            break;
        }
    }
    
    self.font = font;
}

@end
