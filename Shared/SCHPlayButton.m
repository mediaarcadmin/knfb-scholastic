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
@synthesize icon;
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
    self.icon = SCHPlayButtonIconPlay;
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

- (void)setIcon:(SCHPlayButtonIcon)newIcon
{
    icon = newIcon;
    switch (self.icon) {
        case SCHPlayButtonIconPlay:
            self.image = [UIImage imageNamed:@"storyinteraction-video-play"];
            break;
        case SCHPlayButtonIconPause:
            self.image = [UIImage imageNamed:@"storyinteraction-video-pause"];
            break;
        case SCHPlayButtonIconNone:
        default:
            self.image = nil;
            break;
    }
}

- (void)setPlay:(BOOL)setPlay
{
    [self setPlay:setPlay animated:YES];
}

- (void)setPlay:(BOOL)setPlay animated:(BOOL)animated
{
    if (play != setPlay) {
        play = setPlay;
        if (play == NO) {
            self.icon = SCHPlayButtonIconPause;
            self.backgroundColor = [UIColor clearColor];
            self.alpha = 0.0;
        }
        
        void (^toggle)(void) = ^ {
            if (play == YES) {
                self.alpha = 0.0;    
                self.backgroundColor = [UIColor clearColor];
            } else {
                self.alpha = 1.0;
                self.backgroundColor = self.tintedBackgroundColor;
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:toggle completion:^(BOOL finished){
                if (play == YES) {
                    self.alpha = 1.0;
                    self.backgroundColor = [UIColor clearColor];
                    self.icon = SCHPlayButtonIconNone;
                }
            }];
        } else {
            toggle();
        }
        
        if (self.actionBlock != nil) {
            self.actionBlock(self);
        }
    }
}

@end
