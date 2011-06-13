//
//  SCHPlayButton.m
//  Scholastic
//
//  Created by John S. Eddie on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPlayButton.h"

@interface SCHPlayButton ()

- (void)setup;

@end

@implementation SCHPlayButton

@synthesize play;
@synthesize actionBlock;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return(self);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)dealloc 
{
    Block_release(actionBlock), actionBlock = nil;
    
    [super dealloc];
}

- (void)setup
{
    play = NO;
    self.image = [UIImage imageNamed:@"SCHPlayButtonPlay"];    
    actionBlock = nil;
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                        action:@selector(tapped:)];
    [self addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    self.play = !self.play;
}

#pragma mark - Accessors

- (void)setPlay:(BOOL)setPlay
{
    if (play != setPlay) {
        play = setPlay;
        if (play == NO) {
            self.image = [UIImage imageNamed:@"SCHPlayButtonPause"];
            self.alpha = 0.0;
        }
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^ {
            self.alpha = (play == YES ? 0.0 : 1.0);
        } completion:^(BOOL finished){
            if (play == YES) {
                self.alpha = 1.0;
                self.image = nil;
            }
        }];
        if (self.actionBlock != nil) {
            self.actionBlock(self);
        }
    }
}

@end
