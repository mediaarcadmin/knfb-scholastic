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

- (void)setupOpeningView;
- (void)setupMainView;
- (void)clearBuiltWord;
- (void)addLetterToBuiltWord:(SCHStoryInteractionDraggableLetterView *)letter;
- (void)updateTarget;

@end

@implementation SCHStoryInteractionControllerTitleTwister

@synthesize openingScreenTitleLabel;
@synthesize answerBuildTarget;
@synthesize answerHeadingCounts;
@synthesize answerTables;
@synthesize letterTileSize;
@synthesize letterViews;
@synthesize builtWord;

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
            letterView.snapDistanceSq = letterTileSize.width*letterTileSize.height;
            letterView.delegate = self;
            [letterView setDragTargets:[NSArray arrayWithObject:self.answerBuildTarget]];
            [letters addObject:letterView];
            [self.contentsView addSubview:letterView];
            [letterView release];
            x += letterTileSize.width + kLetterGap;
        }
    }
    
    self.letterViews = [NSArray arrayWithArray:letters];
    [self clearBuiltWord];
}

- (void)clearBuiltWord
{
    self.builtWord = [NSMutableArray array];
    [self.letterViews makeObjectsPerformSelector:@selector(moveToOriginalPosition)];
    [self updateTarget];
}

- (void)addLetterToBuiltWord:(SCHStoryInteractionDraggableLetterView *)letter
{
    [self.builtWord addObject:letter];
    [self updateTarget];
}

- (void)updateTarget
{
    CGFloat left = -(CGRectGetWidth(self.answerBuildTarget.bounds) - letterTileSize.width) / 2 + kLetterGap;
    CGFloat nextX = left + (letterTileSize.width + kLetterGap) * [self.builtWord count];
    self.answerBuildTarget.centerOffset = CGPointMake(nextX, 0);
    self.answerBuildTarget.occupied = [self.builtWord count] == 7;
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

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggable didAttachToTarget:(SCHStoryInteractionDraggableTargetView *)target
{
    if (target == self.answerBuildTarget) {
        [self addLetterToBuiltWord:(SCHStoryInteractionDraggableLetterView *)draggable];
    } else {
        // slide the following letters back to fill the gap
        NSInteger pos = [self.builtWord indexOfObject:draggable];
        if (pos != NSNotFound) {
            while (++pos < [self.builtWord count]) {
                UIView *letter = [self.builtWord objectAtIndex:pos];
                CGPoint center = letter.center;
                center.x -= self.letterTileSize.width + kLetterGap;
                [UIView animateWithDuration:0.25
                                 animations:^{
                                     letter.center = center;
                                 }];
            }
        }
        [self.builtWord removeObject:draggable];
        [self updateTarget];
    }
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
