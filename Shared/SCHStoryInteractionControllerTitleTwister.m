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
#import "NSArray+ViewSorting.h"

#define kLetterGap 3

@interface SCHStoryInteractionControllerTitleTwister ()

@property (nonatomic, assign) CGSize letterTileSize;
@property (nonatomic, retain) NSArray *letterViews;
@property (nonatomic, retain) NSMutableArray *builtWord;
@property (nonatomic, assign) NSInteger gapPosition;
@property (nonatomic, retain) NSDictionary *answersByLength;
@property (nonatomic, retain) NSDictionary *answerCountsByLength;

- (void)setupOpeningView;
- (void)setupMainView;
- (void)setupDraggableTilesForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister;
- (void)setupAnswersForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister;

- (void)clearBuiltWord;
- (void)repositionLettersInBuiltWord;
- (NSString *)builtWordAsString;

- (NSInteger)letterPositionForPointInContentsView:(CGPoint)point;
- (NSInteger)letterPositionForPointInTarget:(CGPoint)point;
- (CGPoint)pointInTargetForLetterPosition:(NSInteger)letterPosition;
- (CGPoint)pointInContentsViewForLetterPosition:(NSInteger)letterPosition;

- (void)updateAnswerTableHeadings;

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
@synthesize answersByLength;
@synthesize answerCountsByLength;

- (void)dealloc
{
    [openingScreenTitleLabel release];
    [answerBuildTarget release];
    [answerHeadingCounts release];
    [answerTables release];
    [letterViews release];
    [builtWord release];
    [answersByLength release];
    [answerCountsByLength release];
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

    [self clearBuiltWord];
    [self setupDraggableTilesForTitleTwister:titleTwister];
    [self setupAnswersForTitleTwister:titleTwister];
    [self updateAnswerTableHeadings];
    
    for (UITableView *tableView in self.answerTables) {
        tableView.rowHeight = 22;
    }
}

- (void)setupDraggableTilesForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    [self.letterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger length = [titleTwister.bookTitle length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:length];
    UIImage *letterTile = [UIImage imageNamed:(iPad ? @"storyinteraction-lettertile-ipad" : @"storyinteraction-lettertile-iphone")];
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
    NSInteger y = CGRectGetMinY(self.answerBuildTarget.frame)/2 + letterTileSize.height/2;
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
}

- (void)setupAnswersForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister
{
    int counts[5] = { 0, 0, 0, 0, 0 };
    for (NSString *word in titleTwister.words) {
        NSInteger length = [word length];
        if (3 <= length && length <= 7) {
            counts[length-3]++;
        } else {
            NSLog(@"ignoring %@ due to invalid length", word);
        }
    }

    self.answerCountsByLength = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:counts[0]], [NSNumber numberWithInt:3],
                                 [NSNumber numberWithInt:counts[1]], [NSNumber numberWithInt:4],
                                 [NSNumber numberWithInt:counts[2]], [NSNumber numberWithInt:5],
                                 [NSNumber numberWithInt:counts[3]], [NSNumber numberWithInt:6],
                                 [NSNumber numberWithInt:counts[4]], [NSNumber numberWithInt:7],
                                 nil];
    
    self.answersByLength = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableArray array], [NSNumber numberWithInt:3],
                            [NSMutableArray array], [NSNumber numberWithInt:4],
                            [NSMutableArray array], [NSNumber numberWithInt:5],
                            [NSMutableArray array], [NSNumber numberWithInt:6],
                            [NSMutableArray array], [NSNumber numberWithInt:7],
                            nil];

    self.answerHeadingCounts = [self.answerHeadingCounts viewsSortedHorizontally];
    self.answerTables = [self.answerTables viewsSortedHorizontally];    
}
         
#pragma mark - built word manipulation

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

- (NSString *)builtWordAsString
{
    NSMutableString *word = [NSMutableString stringWithCapacity:[self.builtWord count]];
    for (SCHStoryInteractionDraggableLetterView *letterView in self.builtWord) {
        unichar letter = letterView.letter;
        [word appendString:[NSString stringWithCharacters:&letter length:1]];
    }
    return [NSString stringWithString:word];
}

#pragma mark - Actions

- (void)goButtonTapped:(id)sender
{
    [self presentNextView];
}

- (void)doneButtonTapped:(id)sender
{
    NSString *word = [self builtWordAsString];
    NSInteger length = [word length];
    
    SCHStoryInteractionTitleTwister *titleTwister = (SCHStoryInteractionTitleTwister *)self.storyInteraction;
    if (length < 3 || 7 < length || ![titleTwister.words containsObject:word]) {
        // TODO try again audio?
        [self clearBuiltWord];
        return;
    }
    
    NSMutableArray *answers = [self.answersByLength objectForKey:[NSNumber numberWithInt:length]];
    if (![answers containsObject:word]) {
        [answers addObject:word];
        [[self.answerTables objectAtIndex:length-3] reloadData];
        [self updateAnswerTableHeadings];
    }
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

#pragma mark - answer table headings

- (void)updateAnswerTableHeadings
{
    for (NSInteger i = 0; i < 5; ++i) {
        NSNumber *key = [NSNumber numberWithInt:i+3];
        NSInteger found = [[self.answersByLength objectForKey:key] count];
        NSInteger total = [[self.answerCountsByLength objectForKey:key] integerValue];
        NSString *heading = [NSString stringWithFormat:@"(Found %d of %d)", found, total];
        [[self.answerHeadingCounts objectAtIndex:i] setText:heading];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger index = [self.answerTables indexOfObject:tableView];
    NSNumber *key = [NSNumber numberWithInt:index+3];
    return [[self.answersByLength objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    NSInteger index = [self.answerTables indexOfObject:tableView];
    NSNumber *key = [NSNumber numberWithInt:index+3];
    NSArray *answers = [self.answersByLength objectForKey:key];

    cell.textLabel.text = [answers objectAtIndex:indexPath.row];
    return cell;
}

@end
