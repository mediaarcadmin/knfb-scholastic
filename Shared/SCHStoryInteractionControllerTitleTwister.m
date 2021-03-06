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
#import "SCHUnqueuedAudioPlayer.h"
#import "SCHStoryInteractionControllerDelegate.h"

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
- (NSArray *)splitTitle:(NSString *)title intoWordsToFitRect:(CGRect)rect withTileSize:(CGSize)tileSize wordGap:(NSInteger)wordGap allowSplitWords:(BOOL)allowSplitWords;
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

- (void)loadCachedWordsFromDisk;
- (void)saveCachedWordsToDisk;
- (void)clearCachedWordsFromDisk;

- (BOOL)allWordsMatch;
- (void)titleTwisterComplete;

@end

@implementation SCHStoryInteractionControllerTitleTwister

@synthesize openingScreenTitleLabel;
@synthesize mainInteractionContainerView;
@synthesize resultsContainerView;
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
@synthesize controlButtons;

- (void)dealloc
{
    [openingScreenTitleLabel release];
    [mainInteractionContainerView release];
    [resultsContainerView release];
    [letterContainerView release];
    [answerBuildTarget release];
    [answerHeadingCounts release];
    [answerTables release];
    [letterViews release];
    [builtWord release];
    [answersByLength release];
    [answerCountsByLength release];
    [controlButtons release];
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.openingScreenTitleLabel.font = [UIFont fontWithName:@"Arial Black" size:34];
    } else {
        self.openingScreenTitleLabel.font = [UIFont fontWithName:@"Arial Black" size:32];
    }
    
    self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
}

- (void)setupMainView
{
    SCHStoryInteractionTitleTwister *titleTwister = (SCHStoryInteractionTitleTwister *)self.storyInteraction;

    [self clearBuiltWord];
    [self setupDraggableTilesForTitleTwister:titleTwister];
    [self setupAnswersForTitleTwister:titleTwister];
    [self loadCachedWordsFromDisk];
    [self updateAnswerTableHeadings];
    
    for (UITableView *tableView in self.answerTables) {
        tableView.rowHeight = 22;
        tableView.allowsSelection = NO;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }

    // set the size and position in the current frame geometry such that the autoresizing
    // will leave the view in the right place after rotation
    [UIView animateWithDuration:duration
                     animations:^{
                         CGSize resultsSize = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? CGSizeMake(300, 150) : CGSizeMake(140, 230);

                         // get the button size
                         CGSize buttonSize = [[self.controlButtons objectAtIndex:0] frame].size;
                         CGFloat buttonHeight = 0;
                         
                         // for portrait, the results box needs to move up, and the buttons 
                         // need to move down
                         if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                             buttonHeight = buttonSize.height + 20;
                         }
                         
                         self.resultsContainerView.bounds = (CGRect) { CGPointZero, resultsSize };
                         self.resultsContainerView.center = CGPointMake(CGRectGetMaxX(self.contentsView.bounds)-5-resultsSize.width/2,
                                                                        CGRectGetMaxY(self.contentsView.bounds)-buttonHeight-10-resultsSize.height/2);
                         
                         // move the buttons to the correct place
                         for (UIButton *button in self.controlButtons) {
                             CGRect buttonFrame = button.frame;
                             buttonFrame.origin.y = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? CGRectGetMaxY(self.resultsContainerView.frame) + 7 : CGRectGetMaxY(self.letterContainerView.frame) + 11;
                             button.frame = buttonFrame;
                         }

                     }];
}

- (void)setupDraggableTilesForTitleTwister:(SCHStoryInteractionTitleTwister *)titleTwister
{
    [self.letterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger length = [titleTwister.bookTitle length];
    NSMutableArray *letters = [NSMutableArray arrayWithCapacity:length];
    
    UIImage *letterTile = [UIImage imageNamed:@"storyinteraction-lettertile"];
    self.letterTileSize = letterTile.size;
    NSInteger wordGap = self.letterTileSize.width/3 + kLetterGap;
    NSArray *letterRows = [self splitTitle:titleTwister.bookTitle
                        intoWordsToFitRect:self.letterContainerView.bounds
                              withTileSize:self.letterTileSize
                                   wordGap:wordGap
                           allowSplitWords:NO];
    if (!letterRows) {
        letterTile = [UIImage imageNamed:@"storyinteraction-lettertile-small"];
        self.letterTileSize = letterTile.size;
        wordGap = self.letterTileSize.width / 3 + kLetterGap;
        letterRows = [self splitTitle:titleTwister.bookTitle
                   intoWordsToFitRect:self.letterContainerView.bounds
                         withTileSize:self.letterTileSize
                              wordGap:wordGap
                      allowSplitWords:YES];
    }

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
                SCHStoryInteractionDraggableLetterView *letterView = [[SCHStoryInteractionDraggableLetterView alloc] initWithLetter:letter tileImage:letterTile];
                letterView.center = [self.letterContainerView convertPoint:CGPointMake(x, y) toView:self.contentsView];
                letterView.homePosition = letterView.center;
                letterView.delegate = self;
                [letters addObject:letterView];
                [self.contentsView addSubview:letterView];
                [letterView release];
                x += self.letterTileSize.width + kLetterGap;
            }
        }
        y += self.letterTileSize.height + kLetterGap;
    }
    
    self.gapPosition = NSNotFound;
    self.letterViews = [NSArray arrayWithArray:letters];
}

- (NSArray *)splitTitle:(NSString *)title
     intoWordsToFitRect:(CGRect)rect
           withTileSize:(CGSize)tileSize
                wordGap:(NSInteger)wordGap
        allowSplitWords:(BOOL)allowSplitWords
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
        } else if (wordWidth <= CGRectGetWidth(rect)) {
            // add this word on a new row
            [letterRows addObject:letterRow];
            letterRow = [[word mutableCopy] autorelease];
            width = wordWidth;
        } else if (allowSplitWords) {
            // need to split this word to make it fit
            NSInteger split = (CGRectGetWidth(rect)-wordGap-width) / tileSize.width;
            if (split > 0) {
                if ([letterRow length] > 0) {
                    [letterRow appendString:@" "];
                }
                [letterRow appendString:[word substringToIndex:split]];
            }
            [letterRows addObject:letterRow];
            letterRow = [[[word substringFromIndex:split] mutableCopy] autorelease];
            width = [letterRow length] * (tileSize.width+kLetterGap);
        } else {
            // can't fit this word in the available space - abandon ship!
            return nil;
        }
    }

    if ([letterRow length] > 0) {
        [letterRows addObject:letterRow];
    }

    NSInteger layoutTextHeight = [letterRows count]*self.letterTileSize.height + ([letterRows count]-1)*kLetterGap;
    if (layoutTextHeight > CGRectGetHeight(rect)) {
        // can't fit this word in the available space - abandon ship!
        return nil;
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
    int counts[5] = { 0, 0, 0, 0, 0 };
    for (NSString *word in titleTwister.words) {
        NSInteger length = [word length];
        if (length < 3 || 7 < length) {
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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
    [UIView animateWithDuration:0.25f 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         NSInteger letterPosition = 0;
                         for (SCHStoryInteractionDraggableLetterView *letter in self.builtWord) {
                             if (letterPosition == self.gapPosition) {
                                 letterPosition++;
                             }
                             letter.center = [self pointInContentsViewForLetterPosition:letterPosition];
                             letterPosition++;
                         }
                     }
                     completion:nil];
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
    
    [self clearBuiltWord];
    
    SCHStoryInteractionTitleTwister *titleTwister = (SCHStoryInteractionTitleTwister *)self.storyInteraction;
    if (length < 3 || ![titleTwister.words containsObject:word]) {
        [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:[titleTwister storyInteractionWrongAnswerSoundFilename]];
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
        [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:[titleTwister storyInteractionCorrectAnswerSoundFilename]];
        return;
    }

    [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:[titleTwister storyInteractionCorrectAnswerSoundFilename]];
    [answers addObject:word];
    [answerTable reloadData];
    [self updateAnswerTableHeadings];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[answers count]-1 inSection:0];
        [answerTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });

    if ([self allWordsMatch] == YES) {
        [self titleTwisterComplete];
    }
}

- (void)clearButtonTapped:(id)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        [self enqueueAudioWithPath:@"sfx_delete.mp3" fromBundle:YES];
        [self clearBuiltWord];
    }];
}

#pragma mark - Draggable view delegate

- (void)draggableViewWasTapped:(SCHStoryInteractionDraggableView *)draggableView
{
    if ([self.builtWord containsObject:draggableView]) {
        [self.builtWord removeObject:draggableView];
        [draggableView moveToHomePosition];
    } else if (![self buildTargetIsFull]) {
        self.gapPosition = NSNotFound;
        if (draggableView != nil) {
            [self.builtWord addObject:draggableView];
        }
    } else {
        return;
    }
    [self repositionLettersInBuiltWord];
    [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:@"sfx_dropOK.mp3"];
}

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    NSInteger letterPosition = [self.builtWord indexOfObject:draggableView];
    if (letterPosition != NSNotFound) {
        [self.builtWord removeObject:draggableView];
        self.gapPosition = letterPosition;
    }
        
    [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:@"sfx_pickup.mp3"];
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
        [[SCHUnqueuedAudioPlayer sharedAudioPlayer] playAudioFromMainBundle:@"sfx_dropNo.mp3"];
        [UIView animateWithDuration:0.25f 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [draggableView moveToHomePosition];
                         }
                         completion:nil];
    } else {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3" fromBundle:YES];
        // allow for the fact that the gap position isn't really in the array
        if (letterPosition > self.gapPosition) {
            letterPosition--;
        }
        if (draggableView != nil && letterPosition <= [self.builtWord count]) {
            [self.builtWord insertObject:draggableView atIndex:letterPosition];
        }
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

- (NSInteger)leftmostLetterPosition
{
    NSInteger numberOfPositions = (CGRectGetWidth(self.answerBuildTarget.bounds)-kLetterGap) / (self.letterTileSize.width+kLetterGap);
    return (CGRectGetWidth(self.answerBuildTarget.bounds) - numberOfPositions*(self.letterTileSize.width+kLetterGap))/2;
}

- (NSInteger)letterPositionForPointInTarget:(CGPoint)point
{
    NSInteger leftOffset = [self leftmostLetterPosition];
    return (point.x - leftOffset) / (self.letterTileSize.width + kLetterGap);
}

- (CGPoint)pointInTargetForLetterPosition:(NSInteger)letterPosition
{
    NSInteger leftOffset = [self leftmostLetterPosition];
    return CGPointMake(leftOffset + self.letterTileSize.width/2 + (self.letterTileSize.width + kLetterGap) * letterPosition,
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
        NSNumber *allkey = [NSNumber numberWithInt:0];
        NSInteger found = [[self.answersByLength objectForKey:allkey] count];
        NSInteger total = 0;
        for (NSUInteger i = 0; i < 5; ++i) {
            NSNumber *lengthkey = [NSNumber numberWithInt:i+3];
            total += [[self.answerCountsByLength objectForKey:lengthkey] integerValue];
        }
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

#pragma mark - Loading and Saving Words

- (void)loadCachedWordsFromDisk
{
    if (!self.delegate) {
        return;
    }
    
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/Twister-%d.plist", cacheDir, self.storyInteraction.documentPageNumber];
    
    NSDictionary *loadedDictionary = [NSDictionary dictionaryWithContentsOfFile:fullPath];
    
    if (loadedDictionary) {
        NSMutableDictionary *convertedDictionary = [NSMutableDictionary dictionary];
        
        for (NSString *key in loadedDictionary) {
            NSNumber *convertedKey = [NSNumber numberWithInt:[key intValue]];
            NSMutableArray *convertedObject = [NSMutableArray arrayWithArray:[loadedDictionary objectForKey:key]];
            [convertedDictionary setObject:convertedObject
                                  forKey:convertedKey];
        }

        self.answersByLength = [NSDictionary dictionaryWithDictionary:convertedDictionary];
    }
}

- (void)saveCachedWordsToDisk
{
    if (!self.delegate) {
        return;
    }
    
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/Twister-%d.plist", cacheDir, self.storyInteraction.documentPageNumber];
    
    NSMutableDictionary *savableDictionary = [NSMutableDictionary dictionary];
    
    for (NSNumber *key in self.answersByLength) {
        NSString *convertedKey = [key stringValue];
        [savableDictionary setObject:[self.answersByLength objectForKey:key]
                              forKey:convertedKey];
    }

    BOOL success = [savableDictionary writeToFile:fullPath atomically:YES];
    
    if (success) {
        NSLog(@"Wrote words to plist %@", fullPath);
    } else {
        NSLog(@"Error writing to plist %@", fullPath);
    }
}

- (void)clearCachedWordsFromDisk
{
    if (!self.delegate) {
        return;
    }
    
    NSString *cacheDir = [self.delegate storyInteractionCacheDirectory];
    NSString *fullPath = [NSString stringWithFormat:@"%@/Twister-%d.plist", cacheDir, self.storyInteraction.documentPageNumber];

    NSFileManager *localFileManager = [[[NSFileManager alloc] init] autorelease];
    
    NSError *error = nil;
    
    [localFileManager removeItemAtPath:fullPath error:&error];
    
    if (error) {
        NSLog(@"Error deleting cached SI image: %@", [error localizedDescription]);
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
        cell.textLabel.textColor = [UIColor SCHDarkBlue1Color];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    cell.textLabel.text = [[self answersForTable:tableView] objectAtIndex:indexPath.row];
    return cell;
}

- (void)closeButtonTapped:(id)sender
{
    [self saveCachedWordsToDisk];
    [super closeButtonTapped:sender];
}

- (BOOL)allWordsMatch
{
    BOOL ret = NO;
    BOOL allWordsMatch = YES;

    if (self.answerCountsByLength != nil) {
        for (NSUInteger i = 0; i < 5; ++i) {
            NSNumber *lengthkey = [NSNumber numberWithInt:i+3];
            if ([[self.answersByLength objectForKey:lengthkey] count] <
                [[self.answerCountsByLength objectForKey:lengthkey] integerValue]) {
                allWordsMatch = NO;
                break;
            }
        }

        if (allWordsMatch == YES) {
            ret = YES;
        }
    }

    return ret;
}

- (void)titleTwisterComplete
{
    [self saveCachedWordsToDisk];
    self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
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
    [letterContainerView setUserInteractionEnabled:NO];
    for (UIButton *item in self.controlButtons) {
        [item setUserInteractionEnabled:NO];
    }
}

- (void)storyInteractionEnableUserInteraction
{
    // enable user interaction
    [letterContainerView setUserInteractionEnabled:YES];
    for (UIButton *item in self.controlButtons) {
        [item setUserInteractionEnabled:YES];
    }
}




@end
