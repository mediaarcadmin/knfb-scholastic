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
#import "NSArray+ViewSorting.h"

enum {
    kPreviewImageTag = 1000,
    kSpinnerTag = 1001,
};

@interface SCHStoryInteractionControllerJigsaw ()

@property (nonatomic, assign) NSInteger numberOfPieces;
@property (nonatomic, retain) NSArray *jigsawPieceViews;
@property (nonatomic, retain) SCHStoryInteractionJigsawPaths *jigsawPaths;

- (UIImage *)puzzleImage;

- (void)setupChoosePuzzleView;
- (void)setupPuzzleView;
- (void)beginPuzzleInteraction;

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

- (NSArray *)jigsawPieceViewsForPuzzleSize:(CGSize)puzzleSize
{
    NSMutableArray *pieces = [NSMutableArray arrayWithCapacity:self.numberOfPieces];
    SCHStoryInteractionJigsawPaths *paths = [self jigsawPaths];
    NSString *imagePath = [(SCHStoryInteractionJigsaw *)self.storyInteraction imagePathForPuzzle];
    CGImageRef puzzleImage = [[self imageAtPath:imagePath] CGImage];
    CGSize puzzleImageSize = CGSizeMake(CGImageGetWidth(puzzleImage), CGImageGetHeight(puzzleImage));
    
    NSLog(@"puzzleImageSize=%@", NSStringFromCGSize(puzzleImageSize));
    
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        // get a rectangular sub-image of the puzzle image
        CGRect pieceRect = [paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleImageSize];
        CGRect pieceBounds = (CGRect){CGPointZero, pieceRect.size};
        CGImageRef pieceImage = CGImageCreateWithImageInRect(puzzleImage, pieceRect);

        NSLog(@"piece %d rect=%@ bounds=%@ image=%lu,%lu", pieceIndex, NSStringFromCGRect(pieceRect), NSStringFromCGRect(pieceBounds),
              CGImageGetWidth(pieceImage), CGImageGetHeight(pieceImage));
        
        // create a new piece image by clipping this to the piece mask
        CGImageRef pieceMask = [paths maskFromPathAtIndex:pieceIndex forPuzzleSize:puzzleImageSize];
        CGImageRef maskedImage = CGImageCreateWithMask(pieceImage, pieceMask);
        CGImageRelease(pieceMask);

        // create an image view for this image and frame it within the target puzzle frame
        UIImageView *pieceView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:maskedImage]];
        pieceView.frame = [paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleSize];
        [pieces addObject:pieceView];
        [pieceView release];

        CGImageRelease(maskedImage);
    }
    
    return pieces;
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
        NSArray *views = [self jigsawPieceViewsForPuzzleSize:frame.size];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.jigsawPieceViews = views;
            
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
    CGRect frame = preview.frame;
    [preview removeFromSuperview];
    
    for (UIImageView *piece in self.jigsawPieceViews) {
        CGPoint center = piece.center;
        piece.center = CGPointMake(center.x+frame.origin.x, center.y+frame.origin.y);
        [self.contentsView addSubview:piece];
    }
    
}

@end
