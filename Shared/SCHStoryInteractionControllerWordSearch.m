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

- (void)playQuestionSequence;
- (void)layoutWordViewsMultipleColumns;
- (void)layoutWordViewsSingleColumn;
- (void)letterGridTapped:(UITapGestureRecognizer *)tap;
- (void)wordTapped:(UITapGestureRecognizer *)tap;
- (void)highlightAndReadOutWord:(SCHStoryInteractionStrikeOutLabelView *)view;

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

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    // special question audio handling in this SI
    return NO;
}

- (void)tappedAudioButton:(id)sender withViewAtIndex:(NSInteger)screenIndex
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self playQuestionSequence];
    }];
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
    NSInteger index = 0;
    for (NSString *word in wordSearch.words) {
        SCHStoryInteractionStrikeOutLabelView *label = [[SCHStoryInteractionStrikeOutLabelView alloc] initWithFrame:CGRectZero];
        label.text = [word uppercaseString];
        label.textColor = [UIColor SCHDarkBlue1Color];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.adjustsFontSizeToFitWidth = YES;
        label.tag = index;
        label.strikeOutColor = [colors objectAtIndex:(index % [colors count])]; 
        [views addObject:label];
        [self.wordsContainerView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wordTapped:)];
        [label addGestureRecognizer:tap];
        [label setUserInteractionEnabled:YES];
        [tap release];
        
        [label release];
        ++index;
    }
    self.wordViews = [NSArray arrayWithArray:views];
    
    if (iPad) {
        [self layoutWordViewsMultipleColumns];
    } else {
        [self layoutWordViewsSingleColumn];
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(letterGridTapped:)];
    [self.lettersContainerView addGestureRecognizer:tap];
    [tap release];
    
    [self playQuestionSequence];
}

- (void)layoutWordViewsMultipleColumns
{
    NSInteger wordCount = [self.wordViews count];
    NSInteger kWordInset = 5;
    CGFloat fontSize = 20;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && wordCount >= 7) {
        fontSize = 16;
    }
    
    CGRect containerRect = self.wordsContainerView.bounds;
    NSInteger numberOfRows = 4;
    if (wordCount < 3) {
        numberOfRows = 1;
    } else if (wordCount < 5) {
        numberOfRows = 2;
    } else if (wordCount < 7 || wordCount == 9) {
        numberOfRows = 3;
    } // otherwise leave as default 4

    NSInteger wordsPerRow = ceilf((float)wordCount / numberOfRows);
    CGFloat rowHeight = floorf((CGRectGetHeight(containerRect) - kWordInset*2) / numberOfRows);
    
    for (NSInteger row = 0; row < numberOfRows; ++row) {
        NSInteger wordsThisRow = MIN(wordsPerRow, wordCount-wordsPerRow*row);
        CGFloat maxColWidth = floorf((CGRectGetWidth(containerRect)) / wordsThisRow);
        CGFloat totalWordWidth = 0;
        
        for (NSInteger col = 0; col < wordsThisRow; ++col) {
            UILabel *label = [self.wordViews objectAtIndex:(row*wordsPerRow+col)];
            totalWordWidth += [label.text sizeWithFont:label.font
                                           minFontSize:label.minimumFontSize
                                        actualFontSize:NULL
                                              forWidth:maxColWidth
                                         lineBreakMode:UILineBreakModeClip].width;
        }
        
        // for future reference; code calculates the gaps required between words
        // and applies that gap to each side, so for example, for four words:
        //
        // Gap WORD Gap WORD Gap WORD Gap WORD Gap
        // 
        // Word width is variable, so we use the actual word width to make the 
        // centring look right. 
        
        CGFloat wordGap = (containerRect.size.width - totalWordWidth) / (wordsThisRow + 1);
        
        CGFloat wordXPos = wordGap;
        
        for (NSInteger col = 0; col < wordsThisRow; ++col) {
            UILabel *label = [self.wordViews objectAtIndex:(row*wordsPerRow+col)];
            
            CGFloat actualFontSize = -1;
            
            CGFloat wordWidth = [label.text sizeWithFont:label.font
                                     minFontSize:label.minimumFontSize
                                  actualFontSize:&actualFontSize
                                        forWidth:maxColWidth
                                   lineBreakMode:UILineBreakModeClip].width;
        
            CGRect wordRect = CGRectIntegral(CGRectMake(wordXPos, kWordInset+rowHeight*row, wordWidth, rowHeight));
            
            label.frame = wordRect;
            label.font = [UIFont boldSystemFontOfSize:fontSize];
            
            wordXPos += wordWidth + wordGap;

        }
    }
}

- (void)layoutWordViewsSingleColumn
{
    static const NSInteger kWordInset = 5;
    
    CGRect containerRect = self.wordsContainerView.bounds;
    NSInteger wordCount = [self.wordViews count];
    CGFloat wordHeight = floorf((CGRectGetHeight(containerRect)-kWordInset*2) / wordCount);
    CGRect wordRect = CGRectMake(0, 0, CGRectGetWidth(containerRect)-kWordInset*2, wordHeight);
    
    for (NSInteger index = 0; index < wordCount; ++index) {
        UILabel *label = [self.wordViews objectAtIndex:index];
        label.bounds = wordRect;
        label.center = CGPointMake(floorf(CGRectGetMidX(containerRect)), floorf(kWordInset+wordHeight*index+wordHeight/2));
        label.font = [UIFont boldSystemFontOfSize:17];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            CGRect wordFrame = self.wordsContainerView.frame;
            wordFrame.origin.x = 30;
            wordFrame.origin.y = 10;
            wordFrame.size.width = 140;
            wordFrame.size.height = 230;
            self.wordsContainerView.frame = wordFrame;
            
            CGRect searchFrame = self.lettersContainerView.frame;
            searchFrame.origin.x = 215;
            searchFrame.origin.y = 10;
            self.lettersContainerView.frame = searchFrame;

            [self layoutWordViewsSingleColumn];
        } else {
            CGRect wordFrame = self.wordsContainerView.frame;
            wordFrame.origin.x = 20;
            wordFrame.origin.y = 265;
            wordFrame.size.width = 270;
            wordFrame.size.height = 120;
            self.wordsContainerView.frame = wordFrame;
            
            CGRect searchFrame = self.lettersContainerView.frame;
            searchFrame.origin.x = 39;
            searchFrame.origin.y = 20;
            self.lettersContainerView.frame = searchFrame;
            
            [self layoutWordViewsMultipleColumns];
        }
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)playQuestionSequence
{
    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
    
    SCHStoryInteractionWordSearch *wordSearch = (SCHStoryInteractionWordSearch *)self.storyInteraction;
    [self enqueueAudioWithPath:[wordSearch audioPathForQuestion] fromBundle:NO];
    for (SCHStoryInteractionStrikeOutLabelView *wordView in self.wordViews) {
        wordView.layer.cornerRadius = 8;
        if (!wordView.strikedOut) {
            [self highlightAndReadOutWord:wordView];
        }
    }
}

- (void)highlightAndReadOutWord:(SCHStoryInteractionStrikeOutLabelView *)wordView
{
    [self enqueueAudioWithPath:[(SCHStoryInteractionWordSearch *)self.storyInteraction audioPathForWordAtIndex:wordView.tag]
                    fromBundle:NO
                    startDelay:0.5
        synchronizedStartBlock:^{
            [wordView setBackgroundColor:[UIColor SCHBlue2Color]];
            [wordView setTextColor:[UIColor whiteColor]];
        }
          synchronizedEndBlock:^{
              [wordView setBackgroundColor:[UIColor clearColor]];
              [wordView setTextColor:[UIColor SCHDarkBlue1Color]];
              if (wordView == [self.wordViews lastObject]) {
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }
          }];
}


#pragma mark - SCHStoryInteractionWordSearchContainerViewDelegate

- (void)letterContainer:(SCHStoryInteractionWordSearchContainerView *)containerView
  didSelectFromStartRow:(NSInteger)startRow
            startColumn:(NSInteger)startColumn
                 extent:(NSInteger)extent
             vertically:(BOOL)vertical
{    
    self.tapCount = 0;
    
    if (extent == 1) {
        [containerView clearSelection];
        return;
    }

    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        
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
            [containerView addPermanentHighlightFromStartRow:startRow
                                                 startColumn:startColumn
                                                      extent:extent
                                                    vertical:vertical
                                                   withColor:label.strikeOutColor];
            [containerView clearSelection];
            
            if ([self.remainingWords count] == 0) {
                self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            } else {
                self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause;
            }            
            
            
            if ([self.remainingWords count] == 0) {
                [self enqueueAudioWithPath:[wordSearch storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
                [self enqueueAudioWithPath:[wordSearch audioPathForYouFound] fromBundle:NO];
                [self enqueueAudioWithPath:[wordSearch audioPathForWordAtIndex:index]
                                fromBundle:NO
                                startDelay:0
                    synchronizedStartBlock:^{
                        [label setStrikedOut:YES];
                    }
                      synchronizedEndBlock:nil];

                [self enqueueAudioWithPath:@"sfx_win_y.mp3" fromBundle:YES];
                [self enqueueAudioWithPath:[self audioPathForYouFoundThemAll]
                                fromBundle:NO
                                startDelay:0
                    synchronizedStartBlock:nil
                      synchronizedEndBlock:^{ 
                          [self removeFromHostView];
                      }];
            } else {
                [self enqueueAudioWithPath:[wordSearch storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
                [self enqueueAudioWithPath:[wordSearch audioPathForYouFound] fromBundle:NO];
                [self enqueueAudioWithPath:[wordSearch audioPathForWordAtIndex:index]
                                fromBundle:NO
                                startDelay:0
                    synchronizedStartBlock:^{
                        [label setStrikedOut:YES];
                    }
                      synchronizedEndBlock:^{ 
                          if ([self.remainingWords count] > 0) {
                              self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                          }
                      }];
            }
        } else if (index == NSNotFound) {
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
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.lettersContainerView layoutSubviews];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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

#pragma mark - Gesture handling

- (void)letterGridTapped:(UITapGestureRecognizer *)tap
{
    if (++self.tapCount == 3) {
        [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
            [self enqueueAudioWithPath:[(SCHStoryInteractionWordSearch *)self.storyInteraction dragYourFingerAudioPath] fromBundle:YES];
            self.tapCount = 0;
        }];
    }
}

- (void)wordTapped:(UITapGestureRecognizer *)tap
{
    if (self.controllerState == SCHStoryInteractionControllerStateInteractionInProgress) {
        [self highlightAndReadOutWord:(SCHStoryInteractionStrikeOutLabelView *)tap.view];
    }
}

@end
