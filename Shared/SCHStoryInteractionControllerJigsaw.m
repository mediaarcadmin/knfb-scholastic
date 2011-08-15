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
#import "NSArray+Shuffling.h"
#import "SCHGeometry.h"

enum {
    kPreviewImageTag = 1000,
    kPieceMargin = 5,
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
- (void)checkForCompletion;

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

- (SCHFrameStyle)frameStyleForViewAtIndex:(NSInteger)viewIndex
{
    if (viewIndex == 0) {
        return SCHStoryInteractionTitle;
    }
    return SCHStoryInteractionNoTitle;
}

#pragma mark - choose puzzle View

- (void)setupChoosePuzzleView
{
    [self setTitle:NSLocalizedString(@"Choose Your Puzzle", @"choose your puzzle")];
}

- (void)choosePuzzle:(UIButton *)sender
{
    self.numberOfPieces = sender.tag;
    [self presentNextView];
    [self cancelQueuedAudio];
}

#pragma mark - preview View

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

- (void)generateJigsawPiecesFromImage:(CGImageRef)puzzleImage yieldBlock:(void(^)(CGImageRef image, CGRect frame))yield
{
    SCHStoryInteractionJigsawPaths *paths = [self jigsawPaths];
    CGSize puzzleSize = CGSizeMake(CGImageGetWidth(puzzleImage), CGImageGetHeight(puzzleImage));
    
    // cut out individual pieces from scaled image
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        // get a rectangular sub-image of the puzzle image
        CGRect pieceRect = CGRectIntegral([paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleSize]);
        CGImageRef pieceImage = CGImageCreateWithImageInRect(puzzleImage, pieceRect);

        // create a new piece image by clipping this to the piece mask
        CGImageRef pieceMask = [paths maskFromPathAtIndex:pieceIndex forPuzzleSize:puzzleSize];
        CGImageRef maskedImage = CGImageCreateWithMask(pieceImage, pieceMask);
        CGImageRelease(pieceMask);
        CGImageRelease(pieceImage);
        
        CGRect pieceFrame = CGRectIntegral([paths boundsOfPieceAtIndex:pieceIndex forPuzzleSize:puzzleSize]);
        yield(maskedImage, pieceFrame);

        CGImageRelease(maskedImage);
    }
}

- (SCHStoryInteractionJigsawPreviewView *)puzzlePreviewWithFrame:(CGRect)frame;
{
    SCHStoryInteractionJigsawPreviewView *preview = [[SCHStoryInteractionJigsawPreviewView alloc] initWithFrame:frame];
    preview.image = [self puzzleImage];
    preview.edgeColor = [UIColor whiteColor];
    preview.tag = kPreviewImageTag;
    return [preview autorelease];
}

- (CGImageRef)scaleImage:(CGImageRef)image toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, (CGRect){CGPointZero, size}, image);
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return scaledImage;
}

- (void)setupPuzzleView
{
    [[self.contentsView viewWithTag:kPreviewImageTag] removeFromSuperview];
    [self.puzzleBackground setAlpha:0];
    
    CGRect frame = CGRectInset(self.contentsView.bounds, 30, 10);
    SCHStoryInteractionJigsawPreviewView *preview = [self puzzlePreviewWithFrame:frame];
    preview.paths = [self jigsawPaths];
    [self.contentsView addSubview:preview];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *imagePath = [(SCHStoryInteractionJigsaw *)self.storyInteraction imagePathForPuzzle];
        UIImage *puzzleImage = [self imageAtPath:imagePath];

        CGRect puzzleFrame = SCHAspectFitSizeInTargetRect(puzzleImage.size, self.puzzleBackground.frame);
        self.puzzleBackground.frame = puzzleFrame;
        
        CGImageRef scaledPuzzleImage = [self scaleImage:[puzzleImage CGImage] toSize:puzzleFrame.size];
        NSMutableArray *pieces = [NSMutableArray arrayWithCapacity:self.numberOfPieces];

        [self generateJigsawPiecesFromImage:scaledPuzzleImage yieldBlock:^(CGImageRef pieceImage, CGRect frame) {
            CGImageRetain(pieceImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                // create an image view for this image and frame it within the target puzzle frame
                SCHStoryInteractionJigsawPieceView *pieceView = [[SCHStoryInteractionJigsawPieceView alloc] initWithFrame:frame];
                pieceView.image = pieceImage;
                [pieces addObject:pieceView];
                [pieceView release];
                CGImageRelease(pieceImage);
            });
        }];
        
        CGImageRelease(scaledPuzzleImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.jigsawPieceViews = pieces;
            
            // enable taps on the preview
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
            [preview addGestureRecognizer:tap];
            [tap release];
        });
    });
}

- (void)previewTapped:(id)sender
{
    [self beginPuzzleInteraction];
}

#pragma mark - puzzle interaction

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
        piece.solutionPosition = piece.center;
        piece.homePosition = [[homePositions objectAtIndex:pieceIndex] CGPointValue];
        piece.transform = puzzleTransform;
        piece.dragTransform = CGAffineTransformIdentity;
        piece.snappedTransform = CGAffineTransformIdentity;
        piece.delegate = self;
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

    [self enqueueAudioWithPath:@"sfx_breakpuzzle.mp3" fromBundle:YES];
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
        const CGFloat x = CGRectGetMinX(puzzle)+CGRectGetWidth(puzzle)/(piecesOnTopAndBottom+1)*(i+1);
        add(x, CGRectGetMinY(bounds)+CGRectGetMinY(puzzle)/2);
        add(x, CGRectGetMaxY(bounds)-CGRectGetMinY(puzzle)/2);
    }
    
    NSAssert(self.numberOfPieces == [positions count], @"wrong number of positions");
    return [positions shuffled];
}

- (void)checkForCompletion
{
    NSInteger correctPieces = 0;
    for (SCHStoryInteractionJigsawPieceView *piece in self.jigsawPieceViews) {
        if ([piece isInCorrectPosition]) {
            correctPieces++;
        }
    }
    if (correctPieces == [self.jigsawPieceViews count]) {
        [self enqueueAudioWithPath:@"sfx_winround.mp3" fromBundle:YES];

        CGRect frame = self.puzzleBackground.frame;
        [self.jigsawPieceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.jigsawPieceViews = nil;

        SCHStoryInteractionJigsawPreviewView *completed = [self puzzlePreviewWithFrame:frame];
        [self.contentsView addSubview:completed];
        [UIView animateWithDuration:0.5
                         animations:^{
                             completed.frame = CGRectInset(self.contentsView.bounds, 10, 30);
                         }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self presentNextView];
        });
    }
}

#pragma mark - draggable delegate

- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView
{
    [self enqueueAudioWithPath:@"sfx_pickup.mp3" fromBundle:YES];
}

- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition
{
    SCHStoryInteractionJigsawPieceView *piece = (SCHStoryInteractionJigsawPieceView *)draggableView;
    if ([piece isInCorrectPosition]) {
        *snapPosition = piece.solutionPosition;
        return YES;
    }
    return NO;
}

- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position
{
    SCHStoryInteractionJigsawPieceView *piece = (SCHStoryInteractionJigsawPieceView *)draggableView;
    if ([piece isInCorrectPosition]) {
        [self enqueueAudioWithPath:@"sfx_dropOK.mp3"
                        fromBundle:YES
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [self checkForCompletion];
              }];
    } else {
        [piece moveToHomePosition];
        [self enqueueAudioWithPath:@"sfx_dropNo.mp3" fromBundle:YES];
    }
}

#pragma mark - play again

- (void)playAgain:(id)sender
{
    self.jigsawPaths = nil;
    [self presentNextView];
}

@end
