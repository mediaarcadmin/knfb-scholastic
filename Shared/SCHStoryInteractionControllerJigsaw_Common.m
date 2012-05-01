//
//  SCHStoryInteractionControllerJigsaw.m
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerJigsaw_Common.h"
#import "SCHStoryInteractionJigsawPaths.h"
#import "SCHStoryInteractionJigsaw.h"
#import "SCHStoryInteractionJigsawPiece.h"
#import "SCHStoryInteractionJigsawPieceView.h"
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "NSArray+Shuffling.h"
#import "NSArray+ViewSorting.h"
#import "SCHGeometry.h"

@interface SCHStoryInteractionControllerJigsaw_Common ()

@property (nonatomic, retain) SCHStoryInteractionJigsawPaths *jigsawPaths;
@property (nonatomic, retain) NSArray *pieceShuffledIndex;

- (UIImage *)puzzleImage;

- (void)setupPuzzleView;

@end

@implementation SCHStoryInteractionControllerJigsaw_Common {
    BOOL hasSetupPiecesForOrientation[2];
}

@synthesize puzzleBackground;
@synthesize puzzlePreviewView;
@synthesize numberOfPieces;
@synthesize jigsawPieces;
@synthesize jigsawPieceViews;
@synthesize jigsawPaths;
@synthesize pieceShuffledIndex;

- (void)dealloc
{
    [puzzleBackground release], puzzleBackground = nil;
    [puzzlePreviewView release], puzzlePreviewView = nil;
    [jigsawPieceViews release], jigsawPieceViews = nil;
    [jigsawPieces release], jigsawPieces = nil;
    [jigsawPaths release], jigsawPaths = nil;
    [pieceShuffledIndex release], pieceShuffledIndex = nil;
    [super dealloc];
}

- (void)storyInteractionDisableUserInteraction
{
}

- (void)storyInteractionEnableUserInteraction
{
}

- (NSString *)audioPathForQuestion
{
    return nil;
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    enum SCHStoryInteractionJigsawOrientation orientation =
        (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? kSCHStoryInteractionJigsawOrientationLandscape : kSCHStoryInteractionJigsawOrientationPortrait);
    
    dispatch_block_t setupPieces = ^{
        [self setupPieceViewsForOrientation:orientation puzzleRect:self.puzzleBackground.frame];
        if ([self puzzleIsInteractive]) {
            [self repositionPiecesToSolutionPosition:NO withOrientation:orientation];
        }
    };
    
    if (self.numberOfPieces > 0 && !hasSetupPiecesForOrientation[orientation]) {
        [self setupPiecesForFrame:self.puzzleBackground.frame
                      orientation:orientation
                   withCompletion:^(CGRect frame) {
                       self.puzzleBackground.frame = frame;
                       setupPieces();
                   }];
    } else {
        setupPieces();
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - choose puzzle View

- (void)setupChoosePuzzleView
{
    [self setTitle:NSLocalizedString(@"Choose Your Puzzle", @"choose your puzzle")];
    [self enqueueAudioWithPath:[(SCHStoryInteractionJigsaw *)self.storyInteraction audioPathForChooseYourPuzzle] fromBundle:NO];
}

- (void)choosePuzzle:(UIButton *)sender
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksBefore:^{
        self.numberOfPieces = sender.tag;
        [self presentNextViewAnimated:NO];
    }];
}

#pragma mark - preview View

- (UIImage *)puzzleImage
{
    SCHStoryInteractionJigsaw *jigsaw = (SCHStoryInteractionJigsaw *)self.storyInteraction;
    NSString *path = nil;
    switch (self.numberOfPieces) {
        case 6:
            path = [jigsaw imagePathForEasyPuzzle];
            break;
        case 12:
            path = [jigsaw imagePathForMediumPuzzle];
            break;
        case 20:
            path = [jigsaw imagePathForHardPuzzle];
            break;
    }
    return [self imageAtPath:path];
}

- (SCHStoryInteractionJigsawPreviewView *)puzzlePreviewWithFrame:(CGRect)frame;
{
    SCHStoryInteractionJigsawPreviewView *preview = [[SCHStoryInteractionJigsawPreviewView alloc] initWithFrame:frame];
    preview.autoresizingMask = 0;
    preview.backgroundColor = [UIColor clearColor];
    preview.image = [self puzzleImage];
    preview.edgeColor = [UIColor whiteColor];
    return [preview autorelease];
}

#pragma mark - piece generation and setup

- (enum SCHStoryInteractionJigsawOrientation)currentJigsawOrientation
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return kSCHStoryInteractionJigsawOrientationLandscape;
    } else {
        return kSCHStoryInteractionJigsawOrientationPortrait;
    }
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

- (CGImageRef)newImageByScalingImage:(CGImageRef)image toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, size.width*4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, (CGRect){CGPointZero, size}, image);
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return scaledImage;
}

- (void)setupPiecesForFrame:(CGRect)backgroundFrame
                orientation:(enum SCHStoryInteractionJigsawOrientation)orientation
             withCompletion:(void(^)(CGRect))completion
{
    UIImage *puzzleUIImage = [self puzzleImage];
    CGSize puzzleImageSize = puzzleUIImage.size;
    CGImageRef puzzleImage = CGImageRetain([puzzleUIImage CGImage]);

    hasSetupPiecesForOrientation[orientation] = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        CGRect puzzleFrame = SCHAspectFitSizeInTargetRect(puzzleImageSize, backgroundFrame);

        CGImageRef scaledPuzzleImage = [self newImageByScalingImage:puzzleImage toSize:puzzleFrame.size];
        CGImageRelease(puzzleImage);

        SCHStoryInteractionJigsawPaths *paths = [self jigsawPaths];
        
        for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
            
            // get a rectangular sub-image of the puzzle image
            NSInteger shuffledIndex = [[self.pieceShuffledIndex objectAtIndex:pieceIndex] integerValue];
            CGRect pieceRect = CGRectIntegral([paths boundsOfPieceAtIndex:shuffledIndex forPuzzleSize:puzzleFrame.size]);
            CGImageRef pieceImage = CGImageCreateWithImageInRect(scaledPuzzleImage, pieceRect);
            
            // create a new piece image by clipping this to the piece mask
            CGImageRef pieceMask = [paths newMaskFromPathAtIndex:shuffledIndex forPuzzleSize:puzzleFrame.size];
            CGImageRef maskedImage = CGImageCreateWithMask(pieceImage, pieceMask);
            CGImageRelease(pieceMask);
            CGImageRelease(pieceImage);
            
            CGRect frame = CGRectIntegral([paths boundsOfPieceAtIndex:shuffledIndex forPuzzleSize:puzzleFrame.size]);
            
            SCHStoryInteractionJigsawPiece *piece = [self.jigsawPieces objectAtIndex:pieceIndex];
            [piece setImage:maskedImage forOrientation:orientation];
            [piece setBounds:(CGRect){CGPointZero, frame.size} forOrientation:orientation];
            [piece setSolutionPosition:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)) forOrientation:orientation];
            CGImageRelease(maskedImage);
        }
        
        CGImageRelease(scaledPuzzleImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(puzzleFrame);
        });
    });
}

- (void)setupPuzzleView
{
    [self.puzzlePreviewView removeFromSuperview];
    [self.puzzleBackground setAlpha:0];
    
    self.puzzlePreviewView = [self puzzlePreviewWithFrame:[self puzzlePreviewFrame]];
    self.puzzlePreviewView.paths = [self jigsawPaths];
    [self.contentsView addSubview:self.puzzlePreviewView];

    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:self.numberOfPieces];
    NSMutableArray *pieceViews = [[NSMutableArray alloc] initWithCapacity:self.numberOfPieces];
    NSMutableArray *pieceIndices = [[NSMutableArray alloc] initWithCapacity:self.numberOfPieces];
    for (NSInteger pieceIndex = 0; pieceIndex < self.numberOfPieces; ++pieceIndex) {
        SCHStoryInteractionJigsawPiece *piece = [[SCHStoryInteractionJigsawPiece alloc] init];
        [pieces addObject:piece];
        [piece release];
        
        UIView<SCHStoryInteractionJigsawPieceView> *pieceView = [self newPieceView];
        [pieceViews addObject:pieceView];
        [pieceView release];
        
        [pieceIndices addObject:[NSNumber numberWithInteger:pieceIndex]];
    }
    self.jigsawPieces = [NSArray arrayWithArray:pieces];
    self.jigsawPieceViews = [NSArray arrayWithArray:pieceViews];
    self.pieceShuffledIndex = [pieceIndices shuffled];
    [pieces release];
    [pieceViews release];
    [pieceIndices release];
    
    [self setupPiecesForFrame:self.puzzleBackground.frame
                  orientation:[self currentJigsawOrientation]
               withCompletion:^(CGRect backgroundFrame) {
                   self.puzzleBackground.frame = backgroundFrame;
                   
                   // enable taps on the preview
                   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
                   [self.puzzlePreviewView addGestureRecognizer:tap];
                   [tap release];
               }];
}

#pragma mark - puzzle interaction

- (SCHStoryInteractionJigsawPiece *)pieceForPieceView:(id<SCHStoryInteractionJigsawPieceView>)pieceView
{
    return [self.jigsawPieces objectAtIndex:[self.jigsawPieceViews indexOfObject:pieceView]];
}

- (void)previewTapped:(id)sender
{
    [self.puzzleBackground setAlpha:1.0];
    [self.puzzleBackground setPaths:[self jigsawPaths]];
    [self.puzzleBackground setEdgeColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
    
    [self setupPieceViewsForOrientation:[self currentJigsawOrientation] puzzleRect:[self.puzzlePreviewView puzzleBounds]];
    [self repositionPiecesToSolutionPosition:YES withOrientation:[self currentJigsawOrientation]];
    [self animatePiecesToHomePositionsForOrientation:[self currentJigsawOrientation]];
    
    [self.puzzlePreviewView removeFromSuperview];
    self.puzzlePreviewView = nil;
}

- (BOOL)puzzleIsInteractive
{
    // YES if we have chosen a puzzle and the preview view has been removed
    return self.numberOfPieces > 0 && self.puzzlePreviewView == nil;
}

- (void)checkForCompletion
{
    NSInteger correctPieces = 0;
    for (SCHStoryInteractionJigsawPiece *piece in self.jigsawPieces) {
        if ([piece isInCorrectPosition]) {
            correctPieces++;
        }
    }
    if (correctPieces == [self.jigsawPieces count]) {
        [self enqueueAudioWithPath:@"sfx_winround.mp3" fromBundle:YES];

        CGRect frame = [self.puzzleBackground convertRect:[self.puzzleBackground puzzleBounds] toView:self.contentsView];
        [self.jigsawPieceViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.jigsawPieceViews = nil;

        SCHStoryInteractionJigsawPreviewView *completed = [self puzzlePreviewWithFrame:frame];
        [self.contentsView addSubview:completed];
        [UIView animateWithDuration:0.5
                         animations:^{
                             completed.frame = [self puzzlePreviewFrame];
                         }];
        
        self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self removeFromHostView];
        });
    }
}

#pragma mark - subclass overrides

- (UIView<SCHStoryInteractionJigsawPieceView> *)newPieceView
{
    return nil;
}

- (CGRect)puzzlePreviewFrame
{
    return CGRectZero;
}

- (void)setupPieceViewsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation puzzleRect:(CGRect)puzzleRect
{}

- (void)animatePiecesToHomePositionsForOrientation:(enum SCHStoryInteractionJigsawOrientation)orientation
{}

- (void)repositionPiecesToSolutionPosition:(BOOL)moveToSolutionPosition withOrientation:(UIInterfaceOrientation)orientation
{}

@end
