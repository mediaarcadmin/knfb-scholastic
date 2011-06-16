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

#define kLetterGap 2

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
- (NSArray *)splitTitle:(NSString *)title intoWordsToFitRect:(CGRect)rect withTileSize:(CGSize)tileSize wordGap:(NSInteger)wordGap;
- (NSInteger)widthOfText:(NSString *)text withTileSize:(CGSize)tileSize wordGap:(NSInteger)wordGap;

- (NSInteger)arrayIndexForWordLength:(NSInteger)wordLength;
- (void)clearBuiltWord;
- (void)repositionLettersInBuiltWord;
- (NSString *)builtWordAsString;

- (NSInteger)letterPositionForPointInContentsView:(CGPoint)point;
- (NSInteger)letterPositionForPointInTarget:(CGPoint)point;
- (CGPoint)pointInTargetForLetterPosition:(NSInteger)letterPosition;
- (CGPoint)pointInContentsViewForLetterPosition:(NSInteger)letterPosition;
- (BOOL)buildTargetIsFull;

- (void)updateAnswerTableHeadings;

@end

@implementation SCHStoryInteractionControllerTitleTwister

@synthesize openingScreenTitleLabel;
@synthesize letterContainerView;
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
    [letterContainerView release];
    [answerBuildTarget release];
    [answerHeadingCounts release];
    [answerTables release];
    [letterViews release];
    [builtWord release];
    [answersByLength release];
    [answerCountsByLength release];
    [super dealloc];
}

#pragma mark - view setup

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
    self.openingScreenTitleLabel.font = [UIFont fontWithName:@"Arial Black" size:34];

    [self playBundleAudioWithFilename:[self.storyInteraction storyInteractionOpeningSoundFilename]
                           completion:nil];
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
    [self.letterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger length = [titleTwister.bookTitle length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:length];
    UIImage *letterTile = [UIImage imageNamed:@"storyinteraction-lettertile"];
    self.letterTileSize = letterTile.size;
    NSInteger wordGap = letterTileSize.width/3 + kLetterGap;

    NSArray *letterRows = [self splitTitle:titleTwister.bookTitle
                        intoWordsToFitRect:self.letterContainerView.bounds
                              withTileSize:self.letterTileSize
                                   wordGap:wordGap];
 
    NSInteger height = [letterRows count]*self.letterTileSize.height + ([letterRows count]-1)*kLetterGap;
    NSInteger y = (CGRectGetHeight(self.letterContainerView.bounds)-height)/2 + self.letterTileSize.height/2;
    for (NSString *letterRow in letterRows) {
        NSInteger length = [letterRow length];
        NSInteger width = [self widthOfText:letterRow withTileSize:self.letterTileSize wordGap:wordGap];
        NSInteger x = (CGRectGetWidth(self.letterContainerView.bounds)-width)/2 + self.letterTileSize.width/2;
        for (NSInteger i = 0; i < length; ++i) {
            unichar letter = [letterRow characterAtIndex:i];
            if (letter == ' ') {
                x += wordGap;
            } else {
                // we've calculated the position inside letterContainerView but the actual views are added
                // to contents view so they can be dragged around the full view
                SCHStoryInteractionDraggableLetterView *letterView = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:letter];
                letterView.center = [self.letterContainerView convertPoint:CGPointMake(x, y) toView:self.contentsView];
                letterView.homePosition = letterView.center;
                letterView.delegate = self;
                [letters addObject:letterView];
                [self.contentsView addSubview:letterView];
                [letterView release];
                x += letterTileSize.width + kLetterGap;
            }
        }
        y += letterTileSize.height + kLetterGap;
    }
    
    self.gapPosition = NSNotFound;
    self.letterViews = [NSArray arrayWithArray:letters];
}

- (NSArray *)splitTitle:(NSString *)title intoWordsToFitRect:(CGRect)rect withTileSize:(CGSize)tileSize wordGap:(NSInteger)wordGap
{
    NSArray *words = [title componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *letterRows = [NSMutableArray array];
    NSMutableString *letterRow = [NSMutableString string];
    CGFloat width = 0;
    for (NSString *word in words) {
        CGFloat wordWidth = [word length]*tileSize.width + ([word length]-1)*kLetterGap;
        if (width + wordGap + wordWidth < CGRectGetWidth(rect)) {
            // this word can be fitted on the current line
            if ([letterRow length] > 0) {
                [letterRow appendString:@" "];
            }
            [letterRow appendString:word];
            width += wordGap + wordWidth;
        } else if (wordWidth > CGRectGetWidth(rect)) {
            // this word can't even be fit on a row on its own and must be split
            NSInteger split = (CGRectGetWidth(rect)-wordGap-width) / tileSize.width;
            if (split > 0) {
                if ([letterRow length] > 0) {
                    [letterRow appendString:@" "];
                }
                [letterRow appendString:[word substringToIndex:split]];
            }
            [letterRows addObject:letterRow];
            letterRow = [[word substringFromIndex:split] mutableCopy];
            width = [letterRow length] * (tileSize.width+kLetterGap);
        } else {
            // add this word on a new row
            [letterRows addObject:letterRow];
            letterRow = [word mutableCopy];
            width = wordWidth;
        }
    }
    if ([letterRow length] > 0) {
        [letterRows addObject:letterRow];
    }
    return letterRows;
}

- (NSInteger)widthOfText:(NSString *)text withTileSize:(CGSize)tileSize wordGap:(NSInteger)wordGap
{
    NSInteger width = 0;
    for (NSInteger i = 0, n = [text length]; i < n; ++i) {
        if ([text characterAtIndex:i] == ' ') {
            width += wordGap;
        } else {
            width += tileSize.width + kLetterGap;
        }
    }
    NSLog(@"text:'%@' tileWidth=%f wordGap=%d width=%d", text, tileSize.width, wordGap, width-kLetterGap);
    return width - kLetterGap;
}

- (void)setupAnswersForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        int counts[5] = { 0, 0, 0, 0, 0 };
        for (NSString *word in titleTwister.words) {
            NSInteger length = [word length];
            if (length < 3) {
                NSLog(@"ignoring %@ due to invalid length", word);
            } else {
                counts[[self arrayIndexForWordLength:length]]++;
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
    } else {
        self.answersByLength = [NSDictionary dictionaryWithObject:[NSMutableArray array]
                                                           forKey:[NSNumber numberWithInt:0]];
    }
        
    self.answerHeadingCounts = [self.answerHeadingCounts viewsSortedHorizontally];
    self.answerTables = [self.answerTables viewsSortedHorizontally];    
}
         
- (NSInteger)arrayIndexForWordLength:(NSInteger)wordLength
{
    return MIN(wordLength,7) - 3;
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
                             letterPosition++;
                         }
                     }];
}

- (void)setGapPosition:(NSInteger)newGapPosition
{
    if (newGapPosition != gapPosition) {
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
    if (length < 3 || ![titleTwister.words containsObject:word]) {
        [self playBundleAudioWithFilename:[titleTwister storyInteractionWrongAnswerSoundFilename] completion:nil];
        return;
    }

    NSNumber *answerKey;
    UITableView *answerTable;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        answerKey = [NSNumber numberWithInt:MIN(length, 7)];
        answerTable = [self.answerTables objectAtIndex:[self arrayIndexForWordLength:length]];
    } else {
        answerKey = [NSNumber numberWithInt:0];
        answerTable = [self.answerTables lastObject];
    }
    
    NSMutableArray *answers = [self.answersByLength objectForKey:answerKey];
    if ([answers containsObject:word]) {
        [self playBundleAudioWithFilename:[titleTwister storyInteractionCorrectAnswerSoundFilename] completion:nil];
        return;
    }

    [self playBundleAudioWithFilename:[titleTwister storyInteractionCorrectAnswerSoundFilename] completion:nil];
    [answers addObject:word];
    [answerTable reloadData];
    [self updateAnswerTableHeadings];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[answers count]-1 inSection:0];
        [answerTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

- (void)clearButtonTapped:(id)sender
{
    [self clearBuiltWord];
}

#pragma mark - Draggable view delegate

- (void)draggableViewWasTapped:(SCHStoryInteractionDraggableView *)draggableView
{
    if ([self.builtWord containsObject:draggableView]) {
        [self.builtWord removeObject:draggableView];
        [draggableView moveToHomePosition];
        [self repositionLettersInBuiltWord];
        [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:nil];
        return;
    }

    if ([self buildTargetIsFull]) {
        return;
    }

    self.gapPosition = NSNotFound;
    [self.builtWord addObject:draggableView];
    [self repositionLettersInBuiltWord];
    [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:nil];
}

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    NSInteger letterPosition = [self.builtWord indexOfObject:draggableView];
    if (letterPosition != NSNotFound) {
        [self.builtWord removeObject:draggableView];
        self.gapPosition = letterPosition;
    }
        
    [self playBundleAudioWithFilename:@"sfx_pickup.mp3" completion:nil];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    NSInteger letterPosition = [self letterPositionForPointInContentsView:position];
    if (letterPosition == NSNotFound || [self buildTargetIsFull]) {
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
    if (letterPosition == NSNotFound || [self buildTargetIsFull]) {
        [self playBundleAudioWithFilename:@"sfx_dropNo.mp3" completion:nil];
        [UIView animateWithDuration:0.25
                         animations:^{
                             [draggableView moveToHomePosition];
                         }];
    } else {
        [self playBundleAudioWithFilename:@"sfx_dropOK.mp3" completion:nil];
        // allow for the fact that the gap position isn't really in the array
        if (letterPosition > self.gapPosition) {
            letterPosition--;
        }
        [self.builtWord insertObject:draggableView atIndex:letterPosition];
    }
    self.gapPosition = NSNotFound;
    [self repositionLettersInBuiltWord];
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

- (BOOL)buildTargetIsFull
{
    CGFloat width = ([self.builtWord count]+1) * (self.letterTileSize.width+kLetterGap)-kLetterGap;
    return width >= CGRectGetWidth(self.answerBuildTarget.bounds);
}

#pragma mark - answer table headings

- (void)updateAnswerTableHeadings
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSNumber *key = [NSNumber numberWithInt:0];
        NSInteger found = [[self.answersByLength objectForKey:key] count];
        NSInteger total = [[(SCHStoryInteractionTitleTwister *)self.storyInteraction words] count];
        NSString *heading = [NSString stringWithFormat:@"(%d of %d)", found, total];
        [[self.answerHeadingCounts lastObject] setText:heading];
    } else {
        for (NSInteger i = 0; i < 5; ++i) {
            NSNumber *key = [NSNumber numberWithInt:i+3];
            NSInteger found = [[self.answersByLength objectForKey:key] count];
            NSInteger total = [[self.answerCountsByLength objectForKey:key] integerValue];
            NSString *heading = [NSString stringWithFormat:@"(Found %d of %d)", found, total];
            [[self.answerHeadingCounts objectAtIndex:i] setText:heading];
        }
    }
}

#pragma mark - Table View Data Source

- (NSArray *)answersForTable:(UITableView *)tableView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSInteger index = [self.answerTables indexOfObject:tableView];
        NSNumber *key = [NSNumber numberWithInt:index+3];
        return [self.answersByLength objectForKey:key];
    } else {
        return [self.answersByLength objectForKey:[NSNumber numberWithInt:0]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self answersForTable:tableView] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.textLabel.textColor = [UIColor colorWithRed:0.467 green:0.200 blue:0.745 alpha:1.];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    cell.textLabel.text = [[self answersForTable:tableView] objectAtIndex:indexPath.row];
    return cell;
}

@end
