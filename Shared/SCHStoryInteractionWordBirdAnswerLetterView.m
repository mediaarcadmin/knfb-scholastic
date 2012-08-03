//
//  SCHStoryInteractionWordBirdAnswerView.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWordBirdAnswerLetterView.h"
#import "UIColor+Scholastic.h"

#define kUnderlineThickness 3

@implementation SCHStoryInteractionWordBirdAnswerLetterView

- (id)initWithFrame:(CGRect)frame wordLength:(NSInteger)aWordLength
{
    if ((self = [super initWithFrame:frame])) {
        
        const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

        NSInteger fontSize = iPad?35:26;
        
        if (aWordLength >= 10) {
            fontSize = iPad?28:20;
        }
        
        self.font = [UIFont fontWithName:@"Arial Black" size:fontSize];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = UITextAlignmentCenter;
        self.adjustsFontSizeToFitWidth = NO;
    }
    return self;
}

- (unichar)letter
{
    return [self.text length] > 0 ? [self.text characterAtIndex:0] : 0;
}

- (void)setLetter:(unichar)letter
{
    self.text = [NSString stringWithCharacters:&letter length:1];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [self.textColor CGColor]);
    CGContextSetLineWidth(context, kUnderlineThickness);
    
    CGRect bounds = self.bounds;
    CGRect lineRect = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds)-kUnderlineThickness, CGRectGetWidth(bounds), 1);
    CGRect drawRect = CGRectIntersection(lineRect, rect);
    
    CGContextMoveToPoint(context, CGRectGetMinX(drawRect), CGRectGetMinY(drawRect));
    CGContextAddLineToPoint(context, CGRectGetMaxY(drawRect), CGRectGetMinY(drawRect));
    CGContextDrawPath(context, kCGPathStroke);
}

@end
