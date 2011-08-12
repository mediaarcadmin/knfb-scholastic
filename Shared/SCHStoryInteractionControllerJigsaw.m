//
//  SCHStoryInteractionControllerJigsaw.m
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw.h"
#import "SCHStoryInteractionJigsawPaths.h"
#import "SCHStoryInteractionJigsaw.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "SCHStoryInteractionJigsawPieceView.h"
#import "NSArray+ViewSorting.h"

enum {
    kPreviewImageTag = 1000,
    kSpinnerTag = 1001,
    kPieceMargin = 5
};

@interface SCHStoryInteractionControllerJigsaw ()

@property (nonatomic, assign) NSInteger numberOfPieces;
@property (nonatomic, retain) NSArray *jigsawPieceViews;
@property (nonatomic, retain) SCHStoryInteractionJigsawPaths *jigsawPaths;

- (UIImage *)puzzleImage;

- (void)setupChoosePuzzleView;
- (void)setupPuzzleView;
- (void)beginPuzzleInteraction;
- (NSArray *)homePositionsForPuzzle;

@end

@implementation SCHStoryInteractionControllerJigsaw

@synthesize choosePuzzleButtons;
@synthesize puzzleBackground;
@synthesize numberOfPieces;
@synthesize jigsawPieceViews;
@synthesize jigsawPaths;

- (void)dealloc
{
    [choosePuzzleButtons release], choosePuzzleButtons = nil;
    [puzzleBackground release], puzzleBackground = nil;
    [jigsawPieceViews release], jigsawPieceViews = nil;
    [jigsawPaths release], jigsawPaths = nil;
    [super dealloc];
}

- (void)storyInteractionDisableUserInteraction
{
}

- (void)storyInteractionEnableUserInteraction
{
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    return screenIndex == 0;
}

- (void)setupViewAtIndex:(NSInteger)screenIndex
{
    switch (screenIndex) {
        case 0:
            [self setupChoosePuzzleView];
            break;
        case 1:
            [self setupPuzzleView];
            break;
    }
}

#pragma mark - Choose Puzzle View

- (void)setupChoosePuzzleView
{
    [self setTitle:NSLocalizedString(@"Choose Your Puzzle", @"choose your puzzle")];
}

- (void)choosePuzzle:(UIButton *)sender
{
    self.numberOfPieces = sender.tag;
    [self presentNextView];
}

#pragma mark - Puzzle View

- (UIImage *)puzzleImage
{
    NSString *path = [(SCHStoryInteractionJigsaw *)self.storyInteraction imagePathForPuzzle];
    return [self imageAtPath:path];
}

- (SCHStoryInteractionJigsawPaths *)jigsawPaths
{
    if (jigsawPaths == nil && self.numberOfPieces > 0) {
        NSString *filename = [NSString stringWithFormat:@"Puzzle-%dpc", self.numberOfPieces];
        NSString *pathsFile = [[NSBundle mainBundle] pathForResource:filename ofType:@"xaml"];
        if (!pathsFile) {
            NSLog(@"%@.xaml not found in bundle", filename);
            return nil;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:pathsFile];
        SCHStoryInteractionJigsawPaths *paths = [[SCHStoryInteractionJigsawPaths alloc] initWithData:data];
        self.jigsawPaths = paths;
        [paths release];
    }
    return jigsawPaths;
}

- (void)generateJigsawPiecesForPuzzleSize:(CGSize)puzzleSize yieldBlock:(void(^)(CGImageRef image, CGRect frame))yield
{
    SCHStoryInteractionJigsawPaths *paths = [self jigsawPaths];
    NSString *imagePath = [(SCHStoryInteractionJigsaw *)self.storyInteraction imagePathForPuzzle];
    CGImageRef puzzleImage = [[self imageAtPath:imagePath] CGImage];
    CGSize puzzleImageSize = CGSizeMake(CGImageGetWidth(puzzleImage), CGImageGetHeight(puzzleImage));
    
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        // get a rectangular sub-image of the puzzle image
        CGRect pieceRect = [paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleImageSize];
        CGImageRef pieceImage = CGImageCreateWithImageInRect(puzzleImage, pieceRect);

        // create a new piece image by clipping this to the piece mask
        CGImageRef pieceMask = [paths maskFromPathAtIndex:pieceIndex forPuzzleSize:puzzleImageSize];
        CGImageRef maskedImage = CGImageCreateWithMask(pieceImage, pieceMask);
        CGImageRelease(pieceMask);
        
        CGRect pieceFrame = [paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleSize];
        yield(maskedImage, pieceFrame);

        CGImageRelease(maskedImage);
    }
}

- (void)setupPuzzleView
{
    [self.puzzleBackground setAlpha:0];
    
    CGRect frame = CGRectInset(self.contentsView.bounds, 30, 10);
    SCHStoryInteractionJigsawPreviewView *preview = [[SCHStoryInteractionJigsawPreviewView alloc] initWithFrame:frame];
    preview.paths = [self jigsawPaths];
    preview.image = [self puzzleImage];
    preview.edgeColor = [UIColor whiteColor];
    preview.tag = kPreviewImageTag;
    [self.contentsView addSubview:preview];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    [preview addGestureRecognizer:tap];
    [tap release];
    [preview release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *pieces = [NSMutableArray arrayWithCapacity:self.numberOfPieces];

        [self generateJigsawPiecesForPuzzleSize:self.puzzleBackground.bounds.size yieldBlock:^(CGImageRef image, CGRect frame) {
            CGImageRetain(image);
            dispatch_async(dispatch_get_main_queue(), ^{
                // create an image view for this image and frame it within the target puzzle frame
                SCHStoryInteractionJigsawPieceView *pieceView = [[SCHStoryInteractionJigsawPieceView alloc] initWithFrame:frame];
                pieceView.image = image;
                [pieces addObject:pieceView];
                [pieceView release];
                CGImageRelease(image);
            });
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.jigsawPieceViews = pieces;
            
            // if there's a spinner on the view, the user has already tapped to begin
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.contentsView viewWithTag:kSpinnerTag];
            if (spinner != nil) {
                [spinner removeFromSuperview];
                [self beginPuzzleInteraction];
            }
        });
    });
}

- (void)previewTapped:(id)sender
{
    // if the pieces aren't ready yet, show a spinner until they are
    if (self.jigsawPieceViews == nil) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        spinner.center = CGPointMake(CGRectGetMidX(self.contentsView.bounds), CGRectGetMidY(self.contentsView.bounds));
        spinner.bounds = CGRectMake(0,0,37,37);
        [self.contentsView addSubview:spinner];
        [spinner startAnimating];
        [spinner release];
    } else {
        [self beginPuzzleInteraction];
    }
}

- (void)beginPuzzleInteraction
{
    [self.puzzleBackground setAlpha:1.0];
    [self.puzzleBackground setPaths:[self jigsawPaths]];
    [self.puzzleBackground setEdgeColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
    
    UIView *preview = [self.contentsView viewWithTag:kPreviewImageTag];
    CGAffineTransform puzzleTransform = CGAffineTransformMakeScale(CGRectGetWidth(preview.bounds)/CGRectGetWidth(self.puzzleBackground.bounds),
                                                                   CGRectGetHeight(preview.bounds)/CGRectGetHeight(self.puzzleBackground.bounds));
    [preview removeFromSuperview];
    
    NSArray *homePositions = [self homePositionsForPuzzle];
    NSInteger pieceIndex = 0;
    CGFloat maxPieceWidth = 0, maxPieceHeight = 0;
    for (SCHStoryInteractionJigsawPieceView *piece in self.jigsawPieceViews) {
        CGPoint center = piece.center;
        piece.center = CGPointMake(center.x+CGRectGetMinX(self.puzzleBackground.frame), center.y+CGRectGetMinY(self.puzzleBackground.frame));
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        piece.transform = puzzleTransform;
        [self.contentsView addSubview:piece];
        pieceIndex++;
        maxPieceWidth = MAX(maxPieceWidth, CGRectGetWidth(piece.bounds));
        maxPieceHeight = MAX(maxPieceHeight, CGRectGetHeight(piece.bounds));
    }
    
    // scale the pieces down to fit in the margins around the puzzle background
    CGFloat scale = MIN(CGRectGetMinX(self.puzzleBackground.frame) / (maxPieceWidth + kPieceMargin),
                        CGRectGetMinY(self.puzzleBackground.frame) / (maxPieceHeight + kPieceMargin));
    CGAffineTransform pieceTransform = CGAffineTransformMakeScale(scale, scale);
    [self.puzzleBackground setTransform:puzzleTransform];

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.puzzleBackground.transform = CGAffineTransformIdentity;
                         for (SCHStoryInteractionJigsawPieceView *piece in self.jigsawPieceViews) {
                             [piece moveToHomePosition];
                             [piece setTransform:pieceTransform];
                         }
                     }
                     completion:nil];
}

- (void)addPoint:(CGFloat)x :(CGFloat)y toArray:(NSMutableArray *)array
{
}

- (NSArray *)homePositionsForPuzzle
{
    const CGRect bounds = self.contentsView.bounds;
    const CGRect puzzle = self.puzzleBackground.frame;
    
    NSMutableArray *positions = [NSMutableArray arrayWithCapacity:6];
    void (^add)(CGFloat,CGFloat) = ^(CGFloat x, CGFloat y) {
        [positions addObject:[NSValue valueWithCGPoint:CGPointMake(floorf(x), floorf(y))]];
    };

    NSInteger piecesOnSides = self.numberOfPieces/3;
    for (NSInteger i = 0; i < piecesOnSides; ++i) {
        const CGFloat y = CGRectGetHeight(bounds)/(piecesOnSides+1)*(i+1);
        add(CGRectGetMinX(bounds)+CGRectGetMinX(puzzle)/2, y);
        add(CGRectGetMaxX(bounds)-CGRectGetMinX(puzzle)/2, y);
    }
    
    NSInteger piecesOnTopAndBottom = self.numberOfPieces/2-piecesOnSides;
    for (NSInteger i = 0; i < piecesOnTopAndBottom; ++i) {
        const CGFloat x = CGRectGetWidth(bounds)/(piecesOnTopAndBottom+1)*(i+1);
        add(x, CGRectGetMinY(bounds)+CGRectGetMinY(puzzle)/2);
        add(x, CGRectGetMaxY(bounds)-CGRectGetMinY(puzzle)/2);
    }
    
    NSAssert(self.numberOfPieces == [positions count], @"wrong number of positions");
    return positions;
}

@end
