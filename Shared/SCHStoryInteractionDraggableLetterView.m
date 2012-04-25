//
//  SCHStoryInteractionDraggableLetterView.m
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableLetterView.h"

#define kTileTag 122
#define kLabelTag 123

@implementation SCHStoryInteractionDraggableLetterView

@synthesize letter;

- (id)initWithLetter:(unichar)aLetter tileImage:(UIImage *)tileImage
{
    if ((self = [super initWithFrame:CGRectMake(0, 0, tileImage.size.width, tileImage.size.height)])) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:tileImage];
        iv.frame = self.bounds;
        iv.tag = kTileTag;
        [self addSubview:iv];
        [iv release];
        
        CGFloat fontSize = 30;
        if (tileImage.size.width <= 30) {
            fontSize = 24;
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.text = [NSString stringWithCharacters:&aLetter length:1];
        label.font = [UIFont fontWithName:@"Arial-BoldMT" size:fontSize];
        label.tag = kLabelTag;
        [self addSubview:label];
        [label release];
        
        letter = aLetter;
    }
    return self;
}

- (id)initWithLetter:(unichar)aLetter
{
    return [self initWithLetter:aLetter tileImage:[UIImage imageNamed:@"storyinteraction-lettertile"]];
}

- (void)setLetterColor:(UIColor *)letterColor
{
    [(UILabel *)[self viewWithTag:kLabelTag] setTextColor:letterColor];
}

- (UIColor *)letterColor
{
    return [(UILabel *)[self viewWithTag:kLabelTag] textColor];
}

- (void)setTileImage:(UIImage *)tileImage
{
    UIImageView *iv = (UIImageView *)[self viewWithTag:kTileTag];
    iv.image = tileImage;
    self.bounds = (CGRect){ CGPointZero, tileImage.size };
}

@end
