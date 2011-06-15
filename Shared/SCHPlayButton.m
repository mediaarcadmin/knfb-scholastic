//
//  SCHPlayButton.m
//  Scholastic
//
//  Created by John S. Eddie on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPlayButton.h"

@interface SCHPlayButton ()

@property (nonatomic, retain) UIColor *tintedBackgroundColor;

- (void)setup;

@end

@implementation SCHPlayButton

@synthesize play;
@synthesize actionBlock;
@synthesize tintedBackgroundColor;

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
    [tintedBackgroundColor release], tintedBackgroundColor = nil;
    
    [super dealloc];
}

- (void)setup
{
    tintedBackgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] retain];
    
    play = NO;
    self.image = [UIImage imageNamed:@"SCHPlayButtonPlay"]; 
    self.backgroundColor = self.tintedBackgroundColor;                            
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
            self.backgroundColor = [UIColor clearColor];
            self.alpha = 0.0;
        }
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^ {
            if (play == YES) {
                self.alpha = 0.0;    
                self.backgroundColor = [UIColor clearColor];
            } else {
                self.alpha = 1.0;
                self.backgroundColor = self.tintedBackgroundColor;
            }
        } completion:^(BOOL finished){
            if (play == YES) {
                self.alpha = 1.0;
                self.backgroundColor = [UIColor clearColor];
                self.image = nil;
            }
        }];
        if (self.actionBlock != nil) {
            self.actionBlock(self);
        }
    }
}

@end
