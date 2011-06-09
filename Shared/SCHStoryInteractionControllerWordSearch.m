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
@property (nonatomic, retain) NSMutableArray *remainingWords;
@end

@implementation SCHStoryInteractionControllerWordSearch

@synthesize lettersContainerView;
@synthesize wordsContainerView;
@synthesize wordViews;
@synthesize remainingWords;

- (void)dealloc
{
    [lettersContainerView release];
    [wordsContainerView release];
    [wordViews release];
    [remainingWords release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    [[self.wordViews objectAtIndex:0] setStrikeOutColor:[UIColor redColor]];
    [[self.wordViews objectAtIndex:1] setStrikeOutColor:[UIColor greenColor]];
    [[self.wordViews objectAtIndex:2] setStrikeOutColor:[UIColor cyanColor]];
    [[self.wordViews objectAtIndex:3] setStrikeOutColor:[UIColor magentaColor]];
    [[self.wordViews objectAtIndex:4] setStrikeOutColor:[UIColor orangeColor]];
    [[self.wordViews objectAtIndex:5] setStrikeOutColor:[UIColor brownColor]];
    
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    
    self.wordsContainerView.layer.borderColor = [[UIColor colorWithRed:0.278 green:0.667 blue:0.937 alpha:1.] CGColor];
    self.wordsContainerView.layer.borderWidth = 2;
    self.wordsContainerView.layer.cornerRadius = 10;
    
    for (int i = 0; i < 6; ++i) {
        [[self.wordViews objectAtIndex:i] setText:[wordSearch.words objectAtIndex:i]];
    }
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    UIImage *letterTile = [UIImage imageNamed:(iPad ? @"storyinteraction-lettertile-ipad" : @"storyinteraction-lettertile-iphone")];
    self.lettersContainerView.delegate = self;
    self.lettersContainerView.letterGap = iPad ? 10 : 2;
    [self.lettersContainerView populateFromWordSearchModel:wordSearch
                                       withLetterTileImage:letterTile];

    self.remainingWords = [NSMutableArray array];
    for (NSString *word in wordSearch.words) {
        [self.remainingWords addObject:[word uppercaseString]];
    }
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

    NSInteger index = [wordSearch wordIndexForLetters:selectedLetters];

    if ([self.remainingWords containsObject:selectedLetters]) {
        [self.remainingWords removeObject:selectedLetters];
        SCHStoryInteractionStrikeOutLabelView *label = [self.wordViews objectAtIndex:index];
        [label setStrikedOut:YES];
        [containerView addPermanentHighlightFromCurrentSelectionWithColor:label.strikeOutColor];
        [containerView clearSelection];
        [self playAudioAtPath:[wordSearch audioPathForCorrectAnswer]
                   completion:^{
                       if ([self.remainingWords count] == 0) {
                           [self playAudioAtPath:[wordSearch audioPathForYouFoundThemAll]
                                      completion:^{
                                          [self removeFromHostView];
                                      }];
                       }
                   }];
    } else if (index == NSNotFound) {
        [self playAudioAtPath:[wordSearch audioPathForIncorrectAnswer]
                   completion:^{
                       [containerView clearSelection];
                   }];
    } else {
        // just ignore reselection of an answer already found
        [containerView clearSelection];
    }
}

@end
