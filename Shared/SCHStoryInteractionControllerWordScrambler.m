//
//  SCHStoryInteractionControllerWordScrambler.m
//  Scholastic
//
//  Created by Neil Gall on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerWordScrambler.h"
#import "SCHStoryInteractionWordScrambler.h"
#import "NSArray+Shuffling.h"
#import "SCHGeometry.h"

#define kLetterGap 3
#define kSnapDistanceSq 1400

@interface SCHStoryInteractionControllerWordScrambler ()

@property (nonatomic, retain) NSArray *letterViews;
@property (nonatomic, assign) CGSize letterTileSize;
@property (nonatomic, retain) NSArray *letterPositions;
@property (nonatomic, retain) NSMutableArray *lettersByPosition;
@property (nonatomic, retain) NSArray *hintLetters;
@property (nonatomic, assign) BOOL hasShownHint;

- (NSArray *)wordsInCurrentScrambler;
- (NSInteger)longestRowInCurrentScrambler;
- (BOOL)canLayoutLetterPositionsWithTileSize:(CGSize)tileSize inContainerSize:(CGSize)containerSize;
- (void)layoutLetterPositionsWithTileSize:(CGSize)tileSize inContainerSize:(CGSize)containerSize;

- (void)createAndLayoutLetterViews;
- (void)scrambleLetterPositions;
- (void)layoutLetterViewsWithAnimationDuration:(NSTimeInterval)duration;

- (void)withLetterPositionCloseToPoint:(CGPoint)point :(void(^)(NSInteger letterPosition, BOOL *stop))block;
- (void)swapLetters:(NSArray *)swapViews;

- (BOOL)hasCorrectSolution;
- (void)wordScrambleComplete;

@end

@implementation SCHStoryInteractionControllerWordScrambler

@synthesize clueLabel;
@synthesize lettersContainerView;
@synthesize hintButton;
@synthesize letterViews;
@synthesize letterTileSize;
@synthesize letterPositions;
@synthesize lettersByPosition;
@synthesize hintLetters;
@synthesize hasShownHint;

- (void)dealloc
{
    [clueLabel release];
    [lettersContainerView release];
    [letterViews release];
    [letterPositions release];
    [lettersByPosition release];
    [hintLetters release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;
    self.clueLabel.text = wordScrambler.clue;
    
    UIImage *letterTile = [UIImage imageNamed:@"storyinteraction-lettertile"];
    self.letterTileSize = letterTile.size;

    // determine how many rows and columns of tiles to show
    NSArray *words = [wordScrambler.answer componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"word scrambler : %@", words);
    
    NSInteger maxTilesPerRow = 0;
    for (NSString *word in words) {
        maxTilesPerRow = MAX(maxTilesPerRow, [word length]);
    }

    [self createAndLayoutLetterViews];
    
    // scramble the positions
    [self scrambleLetterPositions];
    
    self.hasShownHint = NO;
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)createAndLayoutLetterViews
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;

    UIImage *letterTile = [UIImage imageNamed:@"storyinteraction-lettertile"];
    if (![self canLayoutLetterPositionsWithTileSize:letterTile.size inContainerSize:self.lettersContainerView.bounds.size]) {
        letterTile = [UIImage imageNamed:@"storyinteraction-lettertile-small"];
    }
    
    NSMutableArray *views = [NSMutableArray array];
    NSMutableArray *hints = [NSMutableArray array];
    NSInteger characterIndex = 1;

    for (NSString *word in [self wordsInCurrentScrambler]) {
        for (NSInteger index = 0, count = [word length]; index < count; ++index) {
            SCHStoryInteractionDraggableLetterView *letter = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:[word characterAtIndex:index]
                                                                                                                  tileImage:letterTile];
            letter.delegate = self;
            [views addObject:letter];
            [self.lettersContainerView addSubview:letter];

            if ([wordScrambler.hintIndices containsObject:[NSNumber numberWithInteger:characterIndex]]) {
                [hints addObject:letter];
            }
            
            [letter release];
            characterIndex++;
        }
        characterIndex++; // for whitespace
    }
    
    self.letterViews = views;
    self.hintLetters = hints;
    
    for (SCHStoryInteractionDraggableLetterView *letter in views) {
        [letter setTileImage:letterTile];
    }
    
    [self layoutLetterPositionsWithTileSize:letterTile.size inContainerSize:self.lettersContainerView.bounds.size];
    self.letterTileSize = letterTile.size;
}

- (NSArray *)wordsInCurrentScrambler
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;
    return [wordScrambler.answer componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSInteger)longestRowInCurrentScrambler
{
    NSInteger longestRow = 0;
    for (NSString *word in [self wordsInCurrentScrambler]) {
        longestRow = MAX(longestRow, [word length]);
    }
    return longestRow;
}

- (BOOL)canLayoutLetterPositionsWithTileSize:(CGSize)tileSize inContainerSize:(CGSize)containerSize
{
    if ([[self wordsInCurrentScrambler] count]*(tileSize.height+kLetterGap)+kLetterGap > containerSize.height) {
        return NO;
    }
        
    if ([self longestRowInCurrentScrambler]*(tileSize.width+kLetterGap)+kLetterGap > containerSize.width) {
        return NO;
    }
    
    return YES;
}

- (void)layoutLetterPositionsWithTileSize:(CGSize)tileSize inContainerSize:(CGSize)containerSize
{
    NSArray *words = [self wordsInCurrentScrambler];
    NSInteger numberOfRows = [words count];
    
    NSInteger maxLettersPerRow = (containerSize.width-kLetterGap) / (tileSize.width+kLetterGap);
    for (NSString *word in words) {
        // split any rows that are too wide
        if ([word length] > maxLettersPerRow) {
            numberOfRows++;
        }
    }
    
    NSMutableArray *positions = [NSMutableArray array];
    
    CGFloat y = (containerSize.height - numberOfRows*tileSize.height - (numberOfRows-1)*kLetterGap)/2 - tileSize.height/2 - kLetterGap;
    for (NSString *word in words) {
        NSInteger length = [word length];
        CGFloat x = 0;
        for (int i = 0; i < length; ++i) {
            if ((i % maxLettersPerRow) == 0) {
                NSInteger lettersThisRow = MIN(length-i, maxLettersPerRow);
                x = (containerSize.width - lettersThisRow*tileSize.width - (lettersThisRow-1)*kLetterGap)/2 + tileSize.width/2;
                y += tileSize.height + kLetterGap;
            }
            [positions addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            x += tileSize.width + kLetterGap;
        }
    }

    self.letterPositions = [NSArray arrayWithArray:positions];
}

- (void)scrambleLetterPositions
{
    self.lettersByPosition = [NSMutableArray array];
    NSArray *shuffledLetters = [self.letterViews shuffled];
    NSInteger index = 0;
    for (NSValue *position in self.letterPositions) {
        SCHStoryInteractionDraggableLetterView *view = [shuffledLetters objectAtIndex:index++];
        view.center = [position CGPointValue];
        view.homePosition = view.center;
        [self.lettersByPosition addObject:view];
    }
}

- (void)layoutLetterViewsWithAnimationDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         for (NSInteger index = 0, count = [self.letterViews count]; index < count; ++index) {
                             SCHStoryInteractionDraggableLetterView *letter = [self.lettersByPosition objectAtIndex:index];
                             letter.center = [[self.letterPositions objectAtIndex:index] CGPointValue];
                             letter.homePosition = letter.center;
                         }
                     }];
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize containerSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        containerSize = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? CGSizeMake(459,124) : CGSizeMake(299,205));
    } else {
        containerSize = self.lettersContainerView.bounds.size;
    }
    
    UIImage *letterTile = [UIImage imageNamed:@"storyinteraction-lettertile"];
    if (![self canLayoutLetterPositionsWithTileSize:letterTile.size inContainerSize:containerSize]) {
        letterTile = [UIImage imageNamed:@"storyinteraction-lettertile-small"];
    }

    for (SCHStoryInteractionDraggableLetterView *letter in self.letterViews) {
        [letter setTileImage:letterTile];
    }
    
    [self layoutLetterPositionsWithTileSize:letterTile.size inContainerSize:containerSize];
    [self layoutLetterViewsWithAnimationDuration:duration];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Actions

- (void)hintButtonTapped:(id)sender
{
    [self playDefaultButtonAudio];
    for (SCHStoryInteractionDraggableLetterView *hintLetter in self.hintLetters) {
        NSInteger hintPosition = [self.letterViews indexOfObject:hintLetter];
        NSInteger hintLetterCurrentPosition = [self.lettersByPosition indexOfObject:hintLetter];
        if (hintLetterCurrentPosition != hintPosition) {
            SCHStoryInteractionDraggableLetterView *letterAtHintPosition = [self.lettersByPosition objectAtIndex:hintPosition];
            [self.lettersByPosition replaceObjectAtIndex:hintPosition withObject:hintLetter];
            [self.lettersByPosition replaceObjectAtIndex:hintLetterCurrentPosition withObject:letterAtHintPosition];

            letterAtHintPosition.homePosition = hintLetter.center;
            hintLetter.homePosition = letterAtHintPosition.center;
            [letterAtHintPosition moveToHomePosition];
            [hintLetter moveToHomePosition];
            hintLetter.lockedInPlace = YES;
        }

        [hintLetter setLetterColor:[UIColor SCHYellowColor]];
    }
    
    self.hasShownHint = YES;
    self.hintButton.hidden = YES;
    
    if ([self hasCorrectSolution]) {
        [self wordScrambleComplete];
    }
}

#pragma mark - draggable delegate

- (BOOL)draggableViewShouldStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    if (self.hasShownHint && [self.hintLetters containsObject:draggableView]) {
        return NO;
    }
    return YES;
}

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self withLetterPositionCloseToPoint:position :^(NSInteger letterPosition, BOOL *stop) {
        SCHStoryInteractionDraggableLetterView *swapLetter = [self.lettersByPosition objectAtIndex:letterPosition];
        if (swapLetter != draggableView && !(self.hasShownHint && [self.hintLetters containsObject:swapLetter])) {
            [self performSelector:@selector(swapLetters:)
                       withObject:[NSArray arrayWithObjects:draggableView, swapLetter, nil]
                       afterDelay:0.75];
            *stop = YES;
        }
    }];
        
    // don't actually snap but set the homePosition so the letter falls there when the drag ends
    *snapPosition = position;
    return YES;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self withLetterPositionCloseToPoint:position :^(NSInteger letterPosition, BOOL *stop) {
        SCHStoryInteractionDraggableLetterView *swapLetter = [self.lettersByPosition objectAtIndex:letterPosition];
        if (swapLetter != draggableView && !(self.hasShownHint && [self.hintLetters containsObject:swapLetter])) {
            [self swapLetters:[NSArray arrayWithObjects:draggableView, swapLetter, nil]];
            *stop = YES;
        }
    }];
    [draggableView moveToHomePosition];
    
    BOOL complete = [self hasCorrectSolution];
    
    if (complete) {
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
    }
    
    [self enqueueAudioWithPath:@"sfx_dropOK.mp3"
                    fromBundle:YES
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              if (complete) {
                  [self wordScrambleComplete];
              }
          }];
}

- (void)withLetterPositionCloseToPoint:(CGPoint)point :(void(^)(NSInteger letterPosition, BOOL *stop))block
{
    for (NSInteger i = 0, n = [self.letterPositions count]; i < n; ++i) {
        CGPoint letterPosition = [[self.letterPositions objectAtIndex:i] CGPointValue];
        if (SCHCGPointDistanceSq(point, letterPosition) < kSnapDistanceSq) {
            BOOL stop = NO;
            block(i, &stop);
            if (stop) {
                break;
            }
        }
    }
}

- (void)swapLetters:(NSArray *)swapViews
{
    SCHStoryInteractionDraggableLetterView *letterView = [swapViews objectAtIndex:0];
    SCHStoryInteractionDraggableLetterView *letterToSwap = [swapViews objectAtIndex:1];
    
    [UIView animateWithDuration:0.25f 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         letterToSwap.center = letterView.homePosition;
                     }
                     completion:nil];
    
    CGPoint newHome = letterToSwap.homePosition;
    letterToSwap.homePosition = letterView.homePosition;
    letterView.homePosition = newHome;
    
    NSInteger draggableIndex = [self.lettersByPosition indexOfObject:letterView];
    NSInteger swappedIndex = [self.lettersByPosition indexOfObject:letterToSwap];
    [self.lettersByPosition replaceObjectAtIndex:draggableIndex withObject:letterToSwap];
    [self.lettersByPosition replaceObjectAtIndex:swappedIndex withObject:letterView];
}

#pragma mark - completion

- (BOOL)hasCorrectSolution
{
    for (NSInteger i = 0, n = [self.letterViews count]; i < n; ++i) {
        if ([[self.lettersByPosition objectAtIndex:i] letter] != [[self.letterViews objectAtIndex:i] letter]) {
            return NO;
        }
    }
    return YES;
}

- (void)wordScrambleComplete
{
    self.hintButton.hidden = YES;
    
    for (SCHStoryInteractionDraggableLetterView *letter in self.letterViews) {
        letter.letterColor = [UIColor SCHYellowColor];
    }

    [self enqueueAudioWithPath:@"sfx_winround.mp3"
                    fromBundle:YES
                    startDelay:0
        synchronizedStartBlock:nil
          synchronizedEndBlock:^{
              [self removeFromHostView];
          }];
}

#pragma mark - Override for SCHStoryInteractionControllerStateReactions

- (void)storyInteractionDisableUserInteraction
{
    // disable user interaction
    for (SCHStoryInteractionDraggableView *source in self.letterViews) {
        [source setUserInteractionEnabled:NO];
    }
    [hintButton setUserInteractionEnabled:NO];    
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    for (SCHStoryInteractionDraggableView *source in self.letterViews) {
        if (!source.lockedInPlace) {
            [source setUserInteractionEnabled:YES];
        }
    }
    [hintButton setUserInteractionEnabled:YES];
}



@end
