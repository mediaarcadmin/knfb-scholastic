//
//  SCHStoryInteractionReadingQuizResultView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionReadingQuizResultView.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHStoryInteractionReadingQuizResultView ()

@property (nonatomic, retain) UILabel *questionLabel;
@property (nonatomic, retain) UILabel *answerLabel;
@property (nonatomic, retain) UIImageView *tickCrossImageView;

@end

@implementation SCHStoryInteractionReadingQuizResultView

@synthesize questionLabel;
@synthesize answerLabel;
@synthesize tickCrossImageView;

- (void)dealloc
{
    [questionLabel release], questionLabel = nil;
    [answerLabel release], answerLabel = nil;
    [tickCrossImageView release], tickCrossImageView = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        questionLabel = [[UILabel alloc] init];
        
        questionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        questionLabel.textAlignment = UITextAlignmentLeft;
        questionLabel.lineBreakMode = UILineBreakModeWordWrap;
        questionLabel.font = [UIFont fontWithName:@"Arial" size:15];
        questionLabel.numberOfLines = 0;
        questionLabel.backgroundColor = [UIColor clearColor];
        questionLabel.textColor = [UIColor SCHDarkBlue1Color];
        
        answerLabel = [[UILabel alloc] init];
        answerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        answerLabel.textAlignment = UITextAlignmentLeft;
        answerLabel.lineBreakMode = UILineBreakModeWordWrap;
        answerLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
        answerLabel.numberOfLines = 0;
        answerLabel.backgroundColor = [UIColor clearColor];
        
        tickCrossImageView = [[UIImageView alloc] init];
        tickCrossImageView.autoresizingMask = UIViewAutoresizingNone;
        tickCrossImageView.contentMode = UIViewContentModeCenter;
        tickCrossImageView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:questionLabel];
        [self addSubview:answerLabel];
        [self addSubview:tickCrossImageView];
        
    }
    return self;
}

- (void)setCorrectAnswer:(NSString *)answer
{
    self.answerLabel.text = answer;
    self.answerLabel.textColor = [UIColor colorWithRed:0.216 green:0.820 blue:0.114 alpha:1];

    self.tickCrossImageView.image = [UIImage imageNamed:@"ReadingQuizAnswerTick"];
}
- (void)setWrongAnswer:(NSString *)answer
{
    self.answerLabel.text = answer;
    self.answerLabel.textColor = [UIColor SCHDarkBlue1Color];
    
    self.tickCrossImageView.image = [UIImage imageNamed:@"ReadingQuizAnswerCross"];
}

- (void)setQuestion:(NSString *)question
{
    self.questionLabel.text = question;
}


- (void)layoutSubviews
{
    const CGFloat inset = 20;
    
    CGRect topFrame = CGRectMake(inset, 0, self.frame.size.width - (inset * 2), floorf(self.frame.size.height / 2));
    CGRect tickCrossFrame = CGRectMake(inset, topFrame.size.height + 1, 30, floorf(self.frame.size.height /2));
    CGRect bottomFrame = CGRectMake(inset + 32, topFrame.size.height + 1, self.frame.size.width - 32 - (inset * 2), floorf(self.frame.size.height / 2));
    
    self.questionLabel.frame = topFrame;
    self.answerLabel.frame = bottomFrame;
    self.tickCrossImageView.frame = tickCrossFrame;
    
//    self.questionLabel.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.answerLabel.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.tickCrossImageView.layer.borderColor = [UIColor orangeColor].CGColor;
//    self.questionLabel.layer.borderWidth = 1;
//    self.answerLabel.layer.borderWidth = 1;
//    self.tickCrossImageView.layer.borderWidth = 1;
    
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
