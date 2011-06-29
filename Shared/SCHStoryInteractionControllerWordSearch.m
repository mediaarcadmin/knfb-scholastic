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
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    
    [[self.wordViews objectAtIndex:0] setStrikeOutColor:[UIColor SCHScholasticRedColor]];
    [[self.wordViews objectAtIndex:1] setStrikeOutColor:[UIColor SCHGreen1Color]];
    [[self.wordViews objectAtIndex:2] setStrikeOutColor:[UIColor SCHLightBlue2Color]];
    [[self.wordViews objectAtIndex:3] setStrikeOutColor:[UIColor SCHPurple1Color]];
    [[self.wordViews objectAtIndex:4] setStrikeOutColor:[UIColor SCHOrange1Color]];
    [[self.wordViews objectAtIndex:5] setStrikeOutColor:[UIColor brownColor]];
    
    self.wordsContainerView.layer.borderColor = [[UIColor SCHLightBlue2Color] CGColor];
    self.wordsContainerView.layer.borderWidth = 2;
    self.wordsContainerView.layer.cornerRadius = 10;
    
    for (int i = 0; i < 6; ++i) {
        [[self.wordViews objectAtIndex:i] setText:[wordSearch.words objectAtIndex:i]];
    }
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    self.lettersContainerView.delegate = self;
    self.lettersContainerView.letterGap = iPad ? 4 : 2;
    [self.lettersContainerView populateFromWordSearchModel:wordSearch];

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
        [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
        [self enqueueAudioWithPath:[wordSearch audioPathForCorrectAnswer] fromBundle:NO];
        if ([self.remainingWords count] == 0) {
            [containerView setUserInteractionEnabled:NO];
            [self enqueueAudioWithPath:[wordSearch audioPathForYouFoundThemAll]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [self removeFromHostViewWithSuccess:YES];
                  }];
        }
    } else if (index == NSNotFound) {
        [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
        [self enqueueAudioWithPath:[wordSearch audioPathForIncorrectAnswer]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [containerView clearSelection];
              }];
    } else {
        // just ignore reselection of an answer already found
        [containerView clearSelection];
    }
}

@end
