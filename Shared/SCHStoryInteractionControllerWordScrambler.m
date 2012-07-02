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

@interface SCHStoryInteractionControllerWordScrambler ()

@property (nonatomic, retain) NSArray *letterRows;
@property (nonatomic, retain) NSArray *letterViews;
@property (nonatomic, assign) CGSize letterTileSize;
@property (nonatomic, retain) NSArray *letterPositions;
@property (nonatomic, retain) NSMutableArray *lettersByPosition;
@property (nonatomic, retain) NSArray *hintLetters;
@property (nonatomic, assign) BOOL hasShownHint;
@property (nonatomic, assign) NSInteger tileGap;
@property (nonatomic, assign) NSInteger snapDistanceSq;

- (void)splitScramblerIntoRows;
- (NSInteger)longestRowInRows:(NSArray *)rows;
- (BOOL)canLayoutLetterPositionsWithTileSize:(CGSize)tileSize letterGap:(NSInteger)gap inContainerSize:(CGSize)containerSize;
- (void)layoutLetterPositionsWithTileSize:(CGSize)tileSize letterGap:(NSInteger)gap inContainerSize:(CGSize)containerSize;

- (UIImage *)chooseLetterTileBackgroundForContainerSize:(CGSize)containerSize;
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
@synthesize letterRows;
@synthesize letterViews;
@synthesize letterTileSize;
@synthesize letterPositions;
@synthesize lettersByPosition;
@synthesize hintLetters;
@synthesize hasShownHint;
@synthesize tileGap;
@synthesize snapDistanceSq;

- (void)dealloc
{
    [letterRows release], letterRows = nil;
    [clueLabel release], clueLabel = nil;
    [lettersContainerView release], lettersContainerView = nil;
    [letterViews release], letterViews = nil;
    [letterPositions release], letterPositions = nil;
    [lettersByPosition release], lettersByPosition = nil;
    [hintLetters release], hintLetters = nil;
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;
    [self setClueLabelText:wordScrambler.clue];

    [self splitScramblerIntoRows];
    [self createAndLayoutLetterViews];
    [self scrambleLetterPositions];
    
    self.hasShownHint = NO;
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setClueLabelText:(NSString *)text
{
    self.clueLabel.text = text;

    NSString *fontName = [self.clueLabel.font fontName];
    CGFloat fontSize = [self.clueLabel.font pointSize];
    CGSize constrainSize = CGSizeMake(CGRectGetWidth(self.clueLabel.bounds), CGFLOAT_MAX);
    UIFont *font = nil;
    while (fontSize > 10) {
        font = [UIFont fontWithName:fontName size:fontSize];
        CGSize size = [text sizeWithFont:font constrainedToSize:constrainSize lineBreakMode:self.clueLabel.lineBreakMode];
        if (size.height <= CGRectGetHeight(self.clueLabel.bounds)) {
            break;
        }
        fontSize -= 1;
    }
    if (font) {
        self.clueLabel.font = font;
    }
}

- (void)createAndLayoutLetterViews
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;

    UIImage *letterTile = [self chooseLetterTileBackgroundForContainerSize:self.lettersContainerView.bounds.size];
    
    NSMutableArray *views = [NSMutableArray array];
    NSMutableArray *hints = [NSMutableArray array];
    NSInteger characterIndex = 1;

    for (NSString *row in self.letterRows) {
        for (NSInteger index = 0, count = [row length]; index < count; ++index) {
            if ([row characterAtIndex:index] == ' ') {
                characterIndex++;
                continue;
            }
            SCHStoryInteractionDraggableLetterView *letter = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:[row characterAtIndex:index]
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
    
    [self layoutLetterPositionsWithTileSize:letterTile.size letterGap:self.tileGap inContainerSize:self.lettersContainerView.bounds.size];
    self.letterTileSize = letterTile.size;
}

- (UIImage *)chooseLetterTileBackgroundForContainerSize:(CGSize)containerSize
{
    static const struct {
        NSString *letterTileName;
        NSInteger letterGap;
    } kLetterTileSizes[] = {
        // must be ordered largest to smallest
        { @"storyinteraction-lettertile",       3 },
        { @"storyinteraction-lettertile-small", 3 },
        { @"storyinteraction-lettertile-tiny",  1 }
    };
    static const size_t kNumLetterTileSizes = sizeof(kLetterTileSizes)/sizeof(kLetterTileSizes[0]);
    
    UIImage *letterTile = nil;
    NSInteger letterGap;
    for (size_t sizeIndex = 0; sizeIndex < kNumLetterTileSizes; ++sizeIndex) {
        UIImage *nextLetterTile = [UIImage imageNamed:kLetterTileSizes[sizeIndex].letterTileName];
        if (!nextLetterTile) {
            // no more tile sizes for this device; use the smallest available
            break;
        }
        letterTile = nextLetterTile;
        letterGap = kLetterTileSizes[sizeIndex].letterGap;
        if ([self canLayoutLetterPositionsWithTileSize:letterTile.size letterGap:letterGap inContainerSize:containerSize]) {
            break;
        }
    }

    NSInteger snapDistance = MIN(37, letterTile.size.width);
    self.snapDistanceSq = snapDistance*snapDistance;
    self.tileGap = letterGap;
    
    return letterTile;
}

- (void)splitScramblerIntoRows
{
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;
    NSCharacterSet *splitCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *rows = [[wordScrambler.answer componentsSeparatedByCharactersInSet:splitCharacters] mutableCopy];
    
    while ([rows count] > 4) {
        // combine two shortest adjacent rows
        NSInteger shortestRowPairIndex = 0;
        NSInteger shortestRowPairLength = NSIntegerMax;
        for (NSInteger rowIndex = 0, rowIndexMax = [rows count]-1; rowIndex < rowIndexMax; ++rowIndex) {
            NSInteger length = [[rows objectAtIndex:rowIndex] length] + [[rows objectAtIndex:rowIndex+1] length] + 1;
            if (length < shortestRowPairLength) {
                shortestRowPairLength = length;
                shortestRowPairIndex = rowIndex;
            }
        }
        NSString *combinedRow = [NSString stringWithFormat:@"%@ %@", [rows objectAtIndex:shortestRowPairIndex], [rows objectAtIndex:shortestRowPairIndex+1]];
        [rows replaceObjectAtIndex:shortestRowPairIndex withObject:combinedRow];
        [rows removeObjectAtIndex:shortestRowPairIndex+1];
    }

    self.letterRows = [NSArray arrayWithArray:rows];
    NSLog(@"scrambler rows: %@", self.letterRows);
    [rows release];
}

- (NSInteger)longestRowInRows:(NSArray *)rows
{
    NSInteger longestRow = 0;
    for (NSString *row in rows) {
        longestRow = MAX(longestRow, [row length]);
    }
    return longestRow;
}

- (BOOL)canLayoutLetterPositionsWithTileSize:(CGSize)tileSize letterGap:(NSInteger)gap inContainerSize:(CGSize)containerSize
{
    if ([self.letterRows count]*(tileSize.height+gap)+gap > containerSize.height) {
        return NO;
    }
        
    if ([self longestRowInRows:self.letterRows]*(tileSize.width+gap)+gap > containerSize.width) {
        return NO;
    }
    
    return YES;
}

- (void)layoutLetterPositionsWithTileSize:(CGSize)tileSize letterGap:(NSInteger)gap inContainerSize:(CGSize)containerSize
{
    NSInteger numberOfRows = [self.letterRows count];
    
    NSInteger maxLettersPerRow = (containerSize.width-gap) / (tileSize.width+gap);
    for (NSString *row in self.letterRows) {
        // split any rows that are too wide
        if ([row length] > maxLettersPerRow) {
            numberOfRows++;
        }
    }
    
    NSMutableArray *positions = [NSMutableArray array];
    
    CGFloat y = (containerSize.height - numberOfRows*tileSize.height - (numberOfRows-1)*gap)/2 - tileSize.height/2 - gap;
    for (NSString *row in self.letterRows) {
        NSInteger length = [row length];
        CGFloat x = 0;
        for (int i = 0; i < length; ++i) {
            if ((i % maxLettersPerRow) == 0) {
                NSInteger lettersThisRow = MIN(length-i, maxLettersPerRow);
                x = (containerSize.width - lettersThisRow*tileSize.width - (lettersThisRow-1)*gap)/2 + tileSize.width/2;
                y += tileSize.height + gap;
            }
            if ([row characterAtIndex:i] != ' ') {
                [positions addObject:[NSValue valueWithCGPoint:CGPointMake(floorf(x), floorf(y))]];
            }
            x += tileSize.width + gap;
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
    
    UIImage *letterTile = [self chooseLetterTileBackgroundForContainerSize:containerSize];

    for (SCHStoryInteractionDraggableLetterView *letter in self.letterViews) {
        [letter setTileImage:letterTile];
    }
    
    [self layoutLetterPositionsWithTileSize:letterTile.size letterGap:self.tileGap inContainerSize:containerSize];
    [self layoutLetterViewsWithAnimationDuration:duration];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Actions

- (void)hintButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];

        for (SCHStoryInteractionDraggableLetterView *hintLetter in self.hintLetters) {
            NSInteger hintPosition = [self.letterViews indexOfObject:hintLetter];
            NSInteger hintLetterCurrentPosition = [self.lettersByPosition indexOfObject:hintLetter];
            if (hintPosition != NSNotFound && hintLetterCurrentPosition != NSNotFound &&
                hintLetterCurrentPosition != hintPosition) {
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
    }];
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
    NSParameterAssert(draggableView);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self withLetterPositionCloseToPoint:position :^(NSInteger letterPosition, BOOL *stop) {
        SCHStoryInteractionDraggableLetterView *swapLetter = [self.lettersByPosition objectAtIndex:letterPosition];
        if (swapLetter != nil
            && draggableView != nil
            && swapLetter != draggableView
            && !(self.hasShownHint && [self.hintLetters containsObject:swapLetter])) {
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
    NSParameterAssert(draggableView);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self withLetterPositionCloseToPoint:position :^(NSInteger letterPosition, BOOL *stop) {
        SCHStoryInteractionDraggableLetterView *swapLetter = [self.lettersByPosition objectAtIndex:letterPosition];
        if (swapLetter != nil
            && draggableView != nil
            && swapLetter != draggableView
            && !(self.hasShownHint && [self.hintLetters containsObject:swapLetter])) {
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
        if (SCHCGPointDistanceSq(point, letterPosition) < self.snapDistanceSq) {
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
    if ([swapViews count] == 2) {
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
        if (draggableIndex != NSNotFound) {
            [self.lettersByPosition replaceObjectAtIndex:draggableIndex withObject:letterToSwap];
        }
        if (swappedIndex != NSNotFound) {
            [self.lettersByPosition replaceObjectAtIndex:swappedIndex withObject:letterView];
        }
    }
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
