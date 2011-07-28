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
@property (nonatomic, retain) NSArray *wordViews;
@property (nonatomic, assign) NSInteger tapCount;

- (void)layoutWordViewsForPad;
- (void)layoutWordViewsForPhone;

@end

@implementation SCHStoryInteractionControllerWordSearch

@synthesize lettersContainerView;
@synthesize wordsContainerView;
@synthesize remainingWords;
@synthesize wordViews;
@synthesize tapCount;

- (void)dealloc
{
    [lettersContainerView release];
    [wordsContainerView release];
    [wordViews release];
    [remainingWords release];
    [super dealloc];
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:[self audioPathForQuestion] fromBundle:NO];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    NSLog(@"words: %@", wordSearch.words);
    
    NSArray *colors = [NSArray arrayWithObjects:
                       [UIColor SCHGreen1Color],
                       [UIColor SCHLightBlue2Color],
                       [UIColor SCHPurple1Color],
                       [UIColor SCHOrange1Color],
                       [UIColor SCHRed2Color],
                       [UIColor SCHGreen2Color],
                       [UIColor SCHBlue1Color],
                       [UIColor SCHOrange2Color],
                       [UIColor SCHGrayColor],
                       nil];
    
    NSMutableArray *views = [NSMutableArray arrayWithCapacity:[wordSearch.words count]];
    NSInteger colorIndex = 0;
    for (NSString *word in wordSearch.words) {
        SCHStoryInteractionStrikeOutLabelView *label = [[SCHStoryInteractionStrikeOutLabelView alloc] initWithFrame:CGRectZero];
        label.text = word;
        label.textColor = [UIColor SCHDarkBlue1Color];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.adjustsFontSizeToFitWidth = YES;
        label.strikeOutColor = [colors objectAtIndex:(colorIndex++ % [colors count])]; 
        [views addObject:label];
        [self.wordsContainerView addSubview:label];
        [label release];
    }
    self.wordViews = [NSArray arrayWithArray:views];
    
    if (iPad) {
        [self layoutWordViewsForPad];
    } else {
        [self layoutWordViewsForPhone];
    }
    
    self.wordsContainerView.layer.borderColor = [[UIColor SCHLightBlue2Color] CGColor];
    self.wordsContainerView.layer.borderWidth = 2;
    self.wordsContainerView.layer.cornerRadius = 10;
    
    self.lettersContainerView.delegate = self;
    self.lettersContainerView.letterGap = iPad ? 4 : 2;
    [self.lettersContainerView populateFromWordSearchModel:wordSearch];

    self.remainingWords = [NSMutableArray array];
    for (NSString *word in wordSearch.words) {
        [self.remainingWords addObject:[word uppercaseString]];
    }
    
    self.tapCount = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.lettersContainerView addGestureRecognizer:tap];
    [tap release];
}

- (void)layoutWordViewsForPad
{
    static const NSInteger kWordInset = 5;
    
    CGRect containerRect = self.wordsContainerView.bounds;
    NSInteger wordCount = [self.wordViews count];
    NSInteger numberOfRows = MAX(1, (wordCount + 3) / 4);
    NSInteger wordsPerRow = wordCount/numberOfRows + (wordCount%2);
    CGFloat rowHeight = (CGRectGetHeight(containerRect) - kWordInset*2) / numberOfRows;
    
    for (NSInteger row = 0; row < numberOfRows; ++row) {
        NSInteger wordsThisRow = MIN(wordsPerRow, wordCount-wordsPerRow*row);
        CGFloat colWidth = (CGRectGetWidth(containerRect) - kWordInset*2) / wordsThisRow;
        CGRect wordRect = CGRectIntegral(CGRectMake(0, 0, colWidth, rowHeight));
        
        for (NSInteger col = 0; col < wordsThisRow; ++col) {
            UILabel *label = [self.wordViews objectAtIndex:(row*wordsPerRow+col)];
            label.bounds = wordRect;
            label.center = CGPointMake(floorf(kWordInset+colWidth*col+colWidth/2), floorf(kWordInset+rowHeight*row+rowHeight/2));
            label.font = [UIFont boldSystemFontOfSize:20];
        }
    }
}

- (void)layoutWordViewsForPhone
{
    static const NSInteger kWordInset = 5;
    
    CGRect containerRect = self.wordsContainerView.bounds;
    NSInteger wordCount = [self.wordViews count];
    CGFloat wordHeight = (CGRectGetHeight(containerRect)-kWordInset*2) / wordCount;
    CGRect wordRect = CGRectMake(0, 0, CGRectGetWidth(containerRect)-kWordInset*2, wordHeight);
    
    for (NSInteger index = 0; index < wordCount; ++index) {
        UILabel *label = [self.wordViews objectAtIndex:index];
        label.bounds = wordRect;
        label.center = CGPointMake(floorf(CGRectGetMidX(containerRect)), floorf(kWordInset+wordHeight*index+wordHeight/2));
        label.font = [UIFont boldSystemFontOfSize:17];
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
        
        if ([self.remainingWords count] == 0) {
            self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        } else {
            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
        }            
        
        
        [self cancelQueuedAudio];
        [self enqueueAudioWithPath:[wordSearch storyInteractionCorrectAnswerSoundFilename]
                        fromBundle:YES];
        [self enqueueAudioWithPath:[wordSearch audioPathForYouFound] fromBundle:NO];
        [self enqueueAudioWithPath:[wordSearch audioPathForWordAtIndex:index]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{ 
                  if ([self.remainingWords count] > 0) {
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }
              }];
        
        if ([self.remainingWords count] == 0) {
            [self enqueueAudioWithPath:[wordSearch audioPathForYouFoundThemAll]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{ 
                      [self removeFromHostView];
                  }];
        }
    } else if (index == NSNotFound) {
        [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
        [self enqueueAudioWithPath:[wordSearch storyInteractionWrongAnswerSoundFilename]
                        fromBundle:YES
                        startDelay:0 synchronizedStartBlock:^{
                            self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
                        }
              synchronizedEndBlock:nil
         ];
        [self enqueueAudioWithPath:[wordSearch audioPathForIncorrectAnswer]
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [containerView clearSelection];
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }];
    } else {
        // just ignore reselection of an answer already found
        [containerView clearSelection];
    }
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    [self.lettersContainerView setUserInteractionEnabled:NO];
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    [self.lettersContainerView setUserInteractionEnabled:YES];
}

#pragma mark - Warn user about tapping

- (void)handleTap:(UIGestureRecognizer *)tap
{
    if (++self.tapCount == 3) {
        [self enqueueAudioWithPath:[(SCHStoryInteractionWordSearch *)self.storyInteraction dragYourFingerAudioPath] fromBundle:NO];
        self.tapCount = 0;
    }
}

@end
