//
//  SCHStoryInteractionControllerWordSearch.m
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionControllerWordSearch.h"
#import "SCHStoryInteractionWordSearch.h"
#import "SCHStoryInteractionStrikeOutLabelView.h"
#import "SCHStoryInteractionWordSearchContainerView.h"

@interface SCHStoryInteractionControllerWordSearch ()

@property (nonatomic, retain) NSArray *wordViews;

@end

@implementation SCHStoryInteractionControllerWordSearch

@synthesize lettersContainerView;
@synthesize wordsContainerView;
@synthesize wordView1;
@synthesize wordView2;
@synthesize wordView3;
@synthesize wordView4;
@synthesize wordView5;
@synthesize wordView6;
@synthesize wordViews;

- (void)dealloc
{
    [lettersContainerView release];
    [wordsContainerView release];
    [wordView1 release];
    [wordView2 release];
    [wordView3 release];
    [wordView4 release];
    [wordView5 release];
    [wordView6 release];
    [wordViews release];
    [super dealloc];
}

- (void)setupView
{
    self.wordView1.strikeOutColor = [UIColor redColor];
    self.wordView2.strikeOutColor = [UIColor greenColor];
    self.wordView3.strikeOutColor = [UIColor cyanColor];
    self.wordView4.strikeOutColor = [UIColor magentaColor];
    self.wordView5.strikeOutColor = [UIColor orangeColor];
    self.wordView6.strikeOutColor = [UIColor brownColor];
    
    self.wordViews = [NSArray arrayWithObjects:self.wordView1, self.wordView2, self.wordView3, self.wordView4, self.wordView5, self.wordView6, nil];
    
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    
    self.wordsContainerView.layer.borderColor = [[UIColor colorWithRed:0.278 green:0.667 blue:0.937 alpha:1.] CGColor];
    self.wordsContainerView.layer.borderWidth = 2;
    self.wordsContainerView.layer.cornerRadius = 10;
    
    for (int i = 0; i < 6; ++i) {
        [[self.wordViews objectAtIndex:i] setText:[wordSearch.words objectAtIndex:i]];
    }
    
    [self.lettersContainerView populateFromWordSearchModel:wordSearch];
    self.lettersContainerView.delegate = self;
}

#pragma mark - SCHStoryInteractionWordSearchContainerViewDelegate

- (void)letterContainer:(SCHStoryInteractionWordSearchContainerView *)containerView
  didSelectFromStartRow:(NSInteger)startRow
            startColumn:(NSInteger)startColumn
                 extent:(NSInteger)extent
             vertically:(BOOL)vertical
{    
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    NSMutableString *selectedLetters = [NSMutableString string];
    for (int i = 0; i < extent; ++i) {
        unichar letter = [wordSearch matrixLetterAtRow:startRow+(vertical?i:0) column:startColumn+(vertical?0:i)];
        [selectedLetters appendString:[NSString stringWithCharacters:&letter length:1]];
    }
    
    for (NSString *word in wordSearch.words) {
        if ([[word uppercaseString] isEqualToString:selectedLetters]) {
            // a match!
            NSInteger index = [wordSearch.words indexOfObject:word];
            SCHStoryInteractionStrikeOutLabelView *label = [self.wordViews objectAtIndex:index];
            [label setStrikedOut:YES];
            [containerView addPermanentHighlightFromCurrentSelectionWithColor:label.strikeOutColor];
        }
    }
    
    [containerView clearSelection];
}

@end
