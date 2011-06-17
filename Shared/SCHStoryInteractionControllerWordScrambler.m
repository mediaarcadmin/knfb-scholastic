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

#define kLetterGap 3
#define kSnapDistanceSq 400

static CGFloat distanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx+dy*dy;
}

@interface SCHStoryInteractionControllerWordScrambler ()

@property (nonatomic, retain) NSArray *letterViews;
@property (nonatomic, assign) CGSize letterTileSize;
@property (nonatomic, retain) NSArray *letterPositions;
@property (nonatomic, retain) NSMutableArray *lettersByPosition;
@property (nonatomic, retain) NSArray *hintLetters;
@property (nonatomic, assign) BOOL hasShownHint;

- (NSInteger)letterPositionCloseToPoint:(CGPoint)point;
- (void)swapLetterAtPosition:(NSInteger)position with:(SCHStoryInteractionDraggableView *)letterView;

- (BOOL)hasCorrectSolution;
- (void)wordScrambleComplete;

@end

@implementation SCHStoryInteractionControllerWordScrambler

@synthesize clueLabel;
@synthesize lettersContainerView;
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

    NSMutableArray *views = [NSMutableArray array];
    NSMutableArray *positions = [NSMutableArray array];
    NSMutableArray *hints = [NSMutableArray array];

    NSInteger numTileRows = [words count];
    CGFloat y = (CGRectGetHeight(self.lettersContainerView.bounds) - numTileRows*letterTileSize.height - (numTileRows-1)*kLetterGap)/2 + letterTileSize.height/2;
    NSInteger characterIndex = 1;
    
    for (NSString *word in words) {
        NSInteger length = [word length];
        CGFloat x = (CGRectGetWidth(self.lettersContainerView.bounds) - length*letterTileSize.width - (length-1)*kLetterGap)/2 + letterTileSize.width/2;
        for (int i = 0; i < length; ++i) {
            SCHStoryInteractionDraggableLetterView *letter = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:[word characterAtIndex:i]];
            letter.delegate = self;
            [positions addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
            [self.lettersContainerView addSubview:letter];
            [views addObject:letter];
            [letter release];
            x += letterTileSize.width + kLetterGap;
            
            // remember the letters at the defined hint indices
            if ([wordScrambler.hintIndices containsObject:[NSNumber numberWithInteger:characterIndex]]) {
                [hints addObject:letter];
            }
            characterIndex++;
        }
        y += letterTileSize.height + kLetterGap;
        characterIndex++; // for the whitespace
    }
    
    self.letterViews = [NSArray arrayWithArray:views];
    self.letterPositions = [NSArray arrayWithArray:positions];
    self.hintLetters = [NSArray arrayWithArray:hints];
    
    // scramble the positions
    self.lettersByPosition = [NSMutableArray array];
    NSArray *shuffledLetters = [views shuffled];
    NSInteger index = 0;
    for (NSValue *position in positions) {
        SCHStoryInteractionDraggableLetterView *view = [shuffledLetters objectAtIndex:index++];
        view.center = [position CGPointValue];
        view.homePosition = view.center;
        [self.lettersByPosition addObject:view];
    }
    
    self.hasShownHint = NO;
}

#pragma mark - Actions

- (void)hintButtonTapped:(id)sender
{
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
        }

        [hintLetter setLetterColor:[UIColor yellowColor]];
    }
    
    self.hasShownHint = YES;
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
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    NSInteger letterPosition = [self letterPositionCloseToPoint:position];
    if (letterPosition == NSNotFound) {
        return NO;
    }
    SCHStoryInteractionDraggableLetterView *swapLetter = [self.lettersByPosition objectAtIndex:letterPosition];
    if (swapLetter == draggableView || (self.hasShownHint && [self.hintLetters containsObject:swapLetter])) {
        return NO;
    }
    
    // don't actually snap but set the homePosition so the letter falls there when the drag ends
    *snapPosition = position;
    [self swapLetterAtPosition:letterPosition with:draggableView];
    return YES;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    [draggableView moveToHomePosition];

    [self playBundleAudioWithFilename:@"sfx_dropOK.mp3"
                           completion:^{
                               if ([self hasCorrectSolution]) {
                                   [self wordScrambleComplete];
                               }
                           }];
}

- (NSInteger)letterPositionCloseToPoint:(CGPoint)point
{
    for (NSInteger i = 0, n = [self.letterPositions count]; i < n; ++i) {
        CGPoint letterPosition = [[self.letterPositions objectAtIndex:i] CGPointValue];
        if (distanceSq(point, letterPosition) < kSnapDistanceSq) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)swapLetterAtPosition:(NSInteger)position with:(SCHStoryInteractionDraggableView *)letterView
{
    SCHStoryInteractionDraggableLetterView *letterToSwap = [self.lettersByPosition objectAtIndex:position];
    [UIView animateWithDuration:0.25
                     animations:^{
                         letterToSwap.center = letterView.homePosition;
                     }];

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
    for (SCHStoryInteractionDraggableLetterView *letter in self.letterViews) {
        letter.letterColor = [UIColor yellowColor];
    }
    
    [self playBundleAudioWithFilename:@"sfx_winround.mp3"
                           completion:^{
                               [self removeFromHostViewWithSuccess:YES];
                           }];
}

@end
