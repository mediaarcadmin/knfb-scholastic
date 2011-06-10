//
//  SCHStoryInteractionControllerWordScrambler.m
//  Scholastic
//
//  Created by Neil Gall on 10/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerWordScrambler.h"
#import "SCHStoryInteractionWordScrambler.h"

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
@property (nonatomic, assign) SCHStoryInteractionDraggableLetterView *tentativeMovedLetter;

- (NSInteger)letterPositionCloseToPoint:(CGPoint)point;
- (void)returnTentativeMovedLetter;
- (void)tentativeSwapLetterAtPosition:(NSInteger)position with:(SCHStoryInteractionDraggableView *)letterView;

@end

@implementation SCHStoryInteractionControllerWordScrambler

@synthesize clueLabel;
@synthesize lettersContainerView;
@synthesize letterViews;
@synthesize letterTileSize;
@synthesize letterPositions;
@synthesize lettersByPosition;
@synthesize tentativeMovedLetter;

- (void)dealloc
{
    [clueLabel release];
    [lettersContainerView release];
    [letterViews release];
    [letterPositions release];
    [lettersByPosition release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    SCHStoryInteractionWordScrambler *wordScrambler = (SCHStoryInteractionWordScrambler *)self.storyInteraction;
    self.clueLabel.text = wordScrambler.clue;
    
    UIImage *letterTile = [UIImage imageNamed:(iPad ? @"storyinteraction-lettertile-ipad" : @"storyinteraction-lettertile-iphone")];
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

    NSInteger numTileRows = [words count];
    CGFloat y = (CGRectGetHeight(self.lettersContainerView.bounds) - numTileRows*letterTileSize.height - (numTileRows-1)*kLetterGap)/2 + letterTileSize.height/2;
    
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
        }
        y += letterTileSize.height + kLetterGap;
    }
    
    self.letterViews = [NSArray arrayWithArray:views];
    self.letterPositions = [NSArray arrayWithArray:positions];
    self.lettersByPosition = [NSMutableArray array];
    
    // scramble the positions
    for (NSValue *position in positions) {
        NSInteger index = arc4random() % [views count];
        SCHStoryInteractionDraggableLetterView *view = [views objectAtIndex:index];
        view.center = [position CGPointValue];
        view.homePosition = view.center;
        [self.lettersByPosition addObject:view];
        [views removeObjectAtIndex:index];
    }
}

#pragma mark - Actions

- (void)hintButtonTapped:(id)sender
{
}

#pragma mark - draggable delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    NSInteger letterPosition = [self letterPositionCloseToPoint:position];
    if (letterPosition == NSNotFound) {
        [self returnTentativeMovedLetter];
        return NO;
    } else {
        *snapPosition = [[self.letterPositions objectAtIndex:letterPosition] CGPointValue];
        [self tentativeSwapLetterAtPosition:letterPosition with:draggableView];
        return YES;
    }
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    NSInteger letterPosition = [self letterPositionCloseToPoint:position];
    if (letterPosition == NSNotFound) {
        [draggableView moveToHomePosition];
        return;
    }
    
    if (self.tentativeMovedLetter) {
        CGPoint newHome = self.tentativeMovedLetter.homePosition;
        self.tentativeMovedLetter.homePosition = draggableView.homePosition;
        draggableView.homePosition = newHome;
        draggableView.center = newHome;
        
        NSInteger draggableIndex = [self.lettersByPosition indexOfObject:draggableView];
        NSInteger swappedIndex = [self.lettersByPosition indexOfObject:self.tentativeMovedLetter];
        [self.lettersByPosition replaceObjectAtIndex:draggableIndex withObject:self.tentativeMovedLetter];
        [self.lettersByPosition replaceObjectAtIndex:swappedIndex withObject:draggableView];

        self.tentativeMovedLetter = nil;
    }
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

- (void)returnTentativeMovedLetter
{
    if (self.tentativeMovedLetter) {
        [self.tentativeMovedLetter moveToHomePosition];
        self.tentativeMovedLetter = nil;
    }
}

- (void)tentativeSwapLetterAtPosition:(NSInteger)position with:(SCHStoryInteractionDraggableView *)letterView
{
    SCHStoryInteractionDraggableLetterView *letter = [self.lettersByPosition objectAtIndex:position];
    if (letter == self.tentativeMovedLetter) {
        // no change
        return;
    }
    
    [self returnTentativeMovedLetter];

    self.tentativeMovedLetter = letter;
    [UIView animateWithDuration:0.25
                     animations:^{
                         letter.center = letterView.homePosition;
                     }];
}

@end
