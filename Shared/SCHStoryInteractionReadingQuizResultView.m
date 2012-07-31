//
//  SCHStoryInteractionReadingQuizResultView.m
//  Scholastic
//
//  Created by Gordon Christie on 27/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoryInteractionReadingQuizResultView.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_GAP 2
#define SIDE_INSET 20
#define IMAGE_WIDTH 30
#define TOP_BOTTOM_INSET 5

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

- (CGFloat)heightForCurrentTextWithWidth:(CGFloat)width
{
//    CGFloat questionHeight = [self.questionLabel.text sizeWithFont:self.questionLabel.font
//                                                       forWidth:width - (2 * SIDE_INSET)
//                                                  lineBreakMode:UILineBreakModeWordWrap].height;
    
//    NSLog(@"Width for question: %f", width - (2 * SIDE_INSET));
//    NSLog(@"Width for answer: %f", width - IMAGE_WIDTH - TEXT_GAP - (2 * SIDE_INSET));
    
    CGFloat questionHeight = [self.questionLabel.text sizeWithFont:self.questionLabel.font constrainedToSize:CGSizeMake(width - (2 * SIDE_INSET), CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    CGFloat answerHeight = [self.answerLabel.text sizeWithFont:self.answerLabel.font constrainedToSize:CGSizeMake(width - IMAGE_WIDTH - TEXT_GAP - (2 * SIDE_INSET), CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;

//    NSLog(@"Getting height. %@ (%f) %@ (%f)", self.questionLabel.text, questionHeight, self.answerLabel.text, answerHeight);
    return questionHeight + TEXT_GAP + answerHeight + (TOP_BOTTOM_INSET * 2);
}


- (void)layoutSubviews
{
    CGFloat questionHeight = [self.questionLabel.text sizeWithFont:self.questionLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - (2 * SIDE_INSET), CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;
    CGFloat answerHeight = [self.answerLabel.text sizeWithFont:self.answerLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - IMAGE_WIDTH - TEXT_GAP - (2 * SIDE_INSET), CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap].height;

    
    CGRect topFrame = CGRectMake(SIDE_INSET, TOP_BOTTOM_INSET, self.frame.size.width - (SIDE_INSET * 2), floorf(questionHeight));
    CGRect tickCrossFrame = CGRectMake(SIDE_INSET, TOP_BOTTOM_INSET + topFrame.size.height + 4, IMAGE_WIDTH, floorf(answerHeight));
    CGRect bottomFrame = CGRectMake(SIDE_INSET + IMAGE_WIDTH + TEXT_GAP, TOP_BOTTOM_INSET + topFrame.size.height + 4, self.frame.size.width - 32 - (SIDE_INSET * 2), floorf(answerHeight));
    
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
