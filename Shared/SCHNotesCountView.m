//
//  SCHNotesCountView.m
//  Scholastic
//
//  Created by Gordon Christie on 31/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHNotesCountView.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kSCHNotesCountViewPaddingWidth = 5;
static const CGFloat kSCHNotesCountViewPaddingHeight = 3;
static const CGFloat kSCHNotesCountViewMinWidth = 21;
static const CGFloat kSCHNotesCountViewMinHeight = 21;

@interface SCHNotesCountView()

@property (nonatomic, retain) UILabel *countLabel;

@end

@implementation SCHNotesCountView

@synthesize noteCount;
@synthesize countLabel;

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    
    if (self) {
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        self.countLabel.textColor = [UIColor whiteColor];
        self.countLabel.backgroundColor = [UIColor clearColor];
        self.countLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.countLabel];
        
    }
    
    return self;
}

- (void) layoutSubviews
{
    if (self.noteCount <= 0) {
        self.hidden = YES;
        return;
    } else {
        self.hidden = NO;
    }
    
    [super layoutSubviews];
    
    CGSize textSize = [self.countLabel.text sizeWithFont:self.countLabel.font];
    textSize.width = MAX(textSize.width, kSCHNotesCountViewMinWidth - 2 * kSCHNotesCountViewPaddingWidth);
    textSize.height = MAX(textSize.height, kSCHNotesCountViewMinHeight - 2 * kSCHNotesCountViewPaddingHeight);
    
    CGRect newFrame = self.frame;
    
    if (self.superview) {
        newFrame.size.width = textSize.width + (kSCHNotesCountViewPaddingWidth * 2);
        newFrame.size.height = textSize.height + (kSCHNotesCountViewPaddingHeight * 2);
        
        newFrame.origin.x = floor(CGRectGetWidth(self.superview.frame)) - newFrame.size.width - 10;
        newFrame.origin.y = 0;

        self.frame = newFrame;
        
        self.countLabel.frame = CGRectMake(kSCHNotesCountViewPaddingWidth, kSCHNotesCountViewPaddingHeight, 
                                           textSize.width, textSize.height);
    }
}

- (void)setNoteCount:(NSInteger)newNoteCount
{
    noteCount = newNoteCount;
    
    // limit the number of notes
    NSInteger limitedNoteCount = noteCount;
    if (limitedNoteCount > 999) {
        limitedNoteCount = 999;
    }
    
    self.countLabel.text = [NSString stringWithFormat:@"%d", limitedNoteCount];
    [self setNeedsLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}

- (void)dealloc
{
    [countLabel release], countLabel = nil;
    [super dealloc];
}

@end
