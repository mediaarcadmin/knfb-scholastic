//
//  SCHStoryInteractionControllerTitleTwister.m
//  Scholastic
//
//  Created by Neil Gall on 09/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerTitleTwister.h"
#import "SCHStoryInteractionTitleTwister.h"
#import "SCHStoryInteractionDraggableLetterView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

#define kLetterGap 5

@interface SCHStoryInteractionControllerTitleTwister ()

@property (nonatomic, assign) CGSize letterTileSize;
@property (nonatomic, retain) NSArray *letterViews;
@property (nonatomic, retain) NSMutableArray *builtWord;
@property (nonatomic, assign) NSInteger gapPosition;

- (void)setupOpeningView;
- (void)setupMainView;
- (void)clearBuiltWord;
- (void)repositionLettersInBuiltWord;

- (NSInteger)letterPositionForPointInContentsView:(CGPoint)point;
- (NSInteger)letterPositionForPointInTarget:(CGPoint)point;
- (CGPoint)pointInTargetForLetterPosition:(NSInteger)letterPosition;
- (CGPoint)pointInContentsViewForLetterPosition:(NSInteger)letterPosition;

@end

@implementation SCHStoryInteractionControllerTitleTwister

@synthesize openingScreenTitleLabel;
@synthesize answerBuildTarget;
@synthesize answerHeadingCounts;
@synthesize answerTables;
@synthesize letterTileSize;
@synthesize letterViews;
@synthesize builtWord;
@synthesize gapPosition;

- (void)dealloc
{
    [openingScreenTitleLabel release];
    [answerBuildTarget release];
    [answerHeadingCounts release];
    [answerTables release];
    [letterViews release];
    [builtWord release];
    [super dealloc];
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    switch (screenIndex) {
        case 0:
            [self setupOpeningView];
            break;
        case 1:
            [self setupMainView];
            break;
    }
}

- (void)setupOpeningView
{ 
    SCHStoryInteractionTitleTwister *titleTwister = (SCHStoryInteractionTitleTwister *)self.storyInteraction;
    self.openingScreenTitleLabel.text = titleTwister.bookTitle;
}

- (void)setupMainView
{
    SCHStoryInteractionTitleTwister *titleTwister = (SCHStoryInteractionTitleTwister *)self.storyInteraction;
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    [self.letterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger length = [titleTwister.bookTitle length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:length];
    UIImage *letterTile = [UIImage imageNamed:(iPad ? @"storyinteraction-wordsearch-letter-ipad" : @"storyinteraction-wordsearch-iphone")];
    self.letterTileSize = letterTile.size;
    
    NSInteger width = 0;
    for (NSInteger i = 0; i < length; ++i) {
        if ([titleTwister.bookTitle characterAtIndex:i] == ' ') {
            width += letterTileSize.width/2 + kLetterGap;
        } else {
            width += letterTileSize.width + kLetterGap;
        }
    }
    
    NSInteger x = (CGRectGetWidth(self.contentsView.bounds) - width) / 2;
    NSInteger y = CGRectGetMinY(self.answerBuildTarget.frame) / 2 + 10;
    for (NSInteger i = 0; i < length; ++i) {
        unichar letter = [titleTwister.bookTitle characterAtIndex:i];
        if (letter == ' ') {
            x += letterTileSize.width/2 + kLetterGap;
        } else {
            SCHStoryInteractionDraggableLetterView *letterView = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:letter];
            letterView.center = CGPointMake(x + CGRectGetMidX(letterView.bounds), y + CGRectGetMidY(letterView.bounds));
            letterView.homePosition = letterView.center;
            letterView.delegate = self;
            [letters addObject:letterView];
            [self.contentsView addSubview:letterView];
            [letterView release];
            x += letterTileSize.width + kLetterGap;
        }
    }
    
    self.gapPosition = NSNotFound;
    self.letterViews = [NSArray arrayWithArray:letters];
    [self clearBuiltWord];
}

#pragma mark - built word modification

- (void)clearBuiltWord
{
    self.builtWord = [NSMutableArray array];
    [self.letterViews makeObjectsPerformSelector:@selector(moveToHomePosition)];
}

- (void)repositionLettersInBuiltWord
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         NSInteger letterPosition = 0;
                         for (SCHStoryInteractionDraggableLetterView *letter in self.builtWord) {
                             if (letterPosition == self.gapPosition) {
                                 letterPosition++;
                             }
                             letter.center = [self pointInContentsViewForLetterPosition:letterPosition];
                             NSLog(@"letter %d '%c' %@", letterPosition, letter.letter, NSStringFromCGPoint(letter.center)); 
                             letterPosition++;
                         }
                     }];
}

- (void)setGapPosition:(NSInteger)newGapPosition
{
    if (newGapPosition != gapPosition) {
        NSLog(@"move gapPosition from %d to %d", gapPosition, newGapPosition);
        gapPosition = newGapPosition;
        [self repositionLettersInBuiltWord];
    }
}

#pragma mark - Actions

- (void)goButtonTapped:(id)sender
{
    [self presentNextView];
}

- (void)doneButtonTapped:(id)sender
{
    
}

- (void)clearButtonTapped:(id)sender
{
    [self clearBuiltWord];
}

#pragma mark - Draggable view delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self.builtWord removeObject:draggableView];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    NSInteger letterPosition = [self letterPositionForPointInContentsView:position];
    if (letterPosition == NSNotFound) {
        self.gapPosition = NSNotFound;
        return NO;
    }

    self.gapPosition = letterPosition;

    // don't really snap, but undo the move from repositionLettersInBuiltWord
    *snapPosition = position;
    return YES;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    NSInteger letterPosition = [self letterPositionForPointInContentsView:position];
    if (letterPosition == NSNotFound) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             [draggableView moveToHomePosition];
                         }];
    } else {
        // allow for the fact that the gap position isn't really in the array
        if (letterPosition > self.gapPosition) {
            letterPosition--;
        }
        [self.builtWord insertObject:draggableView atIndex:letterPosition];
    }
    self.gapPosition = NSNotFound;
}

#pragma mark - Target letter positions

- (NSInteger)letterPositionForPointInContentsView:(CGPoint)point
{
    CGRect frame = [self.answerBuildTarget convertRect:self.answerBuildTarget.frame toView:self.contentsView];
    if (!CGRectContainsPoint(frame, point)) {
        return NSNotFound;
    }
    CGPoint pointInTarget = [self.answerBuildTarget convertPoint:point fromView:self.contentsView];
    NSInteger letterPosition = [self letterPositionForPointInTarget:pointInTarget];
    return MAX(0, MIN(letterPosition, [self.builtWord count]));
}

- (NSInteger)letterPositionForPointInTarget:(CGPoint)point
{
    return (point.x - kLetterGap) / (self.letterTileSize.width + kLetterGap);
}

- (CGPoint)pointInTargetForLetterPosition:(NSInteger)letterPosition
{
    return CGPointMake(kLetterGap + self.letterTileSize.width/2 + (self.letterTileSize.width + kLetterGap) * letterPosition,
                       CGRectGetMidY(self.answerBuildTarget.bounds));
}

- (CGPoint)pointInContentsViewForLetterPosition:(NSInteger)letterPosition
{
    CGPoint pointInTarget = [self pointInTargetForLetterPosition:letterPosition];
    return [self.answerBuildTarget convertPoint:pointInTarget toView:self.contentsView];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
