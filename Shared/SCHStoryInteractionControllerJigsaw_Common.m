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
#import "SCHStoryInteractionJigsawPreviewView.h"
#import "SCHStoryInteractionJigsawPieceView.h"
#import "NSArray+ViewSorting.h"
#import "SCHGeometry.h"

enum {
    kPreviewImageTag = 1000,
};

@interface SCHStoryInteractionControllerJigsaw_Common ()

@property (nonatomic, retain) SCHStoryInteractionJigsawPaths *jigsawPaths;

- (UIImage *)puzzleImage;

- (void)setupChoosePuzzleView;
- (void)setupPuzzleView;

@end

@implementation SCHStoryInteractionControllerJigsaw_Common

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
        [self presentNextView];
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
        CGImageRef pieceMask = [paths newMaskFromPathAtIndex:pieceIndex forPuzzleSize:puzzleSize];
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

- (void)setupPuzzleView
{
    [[self.contentsView viewWithTag:kPreviewImageTag] removeFromSuperview];
    [self.puzzleBackground setAlpha:0];
    
    SCHStoryInteractionJigsawPreviewView *preview = [self puzzlePreviewWithFrame:[self puzzlePreviewFrame]];
    preview.paths = [self jigsawPaths];
    [self.contentsView addSubview:preview];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *puzzleImage = [self puzzleImage];
        CGRect puzzleFrame = SCHAspectFitSizeInTargetRect(puzzleImage.size, self.puzzleBackground.frame);
        self.puzzleBackground.frame = puzzleFrame;
        
        CGImageRef scaledPuzzleImage = [self newImageByScalingImage:[puzzleImage CGImage] toSize:puzzleFrame.size];
        NSMutableArray *pieces = [NSMutableArray arrayWithCapacity:self.numberOfPieces];

        [self generateJigsawPiecesFromImage:scaledPuzzleImage yieldBlock:^(CGImageRef pieceImage, CGRect frame) {
            CGImageRetain(pieceImage);
            dispatch_async(dispatch_get_main_queue(), ^{
                // create an image view for this image and frame it within the target puzzle frame
                UIView *pieceView = [self newPieceViewForImage:pieceImage];
                pieceView.frame = frame;
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

#pragma mark - puzzle interaction

- (void)previewTapped:(id)sender
{
    [self.puzzleBackground setAlpha:1.0];
    [self.puzzleBackground setPaths:[self jigsawPaths]];
    [self.puzzleBackground setEdgeColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
    
    SCHStoryInteractionJigsawPreviewView *preview = (SCHStoryInteractionJigsawPreviewView *)[self.contentsView viewWithTag:kPreviewImageTag];    
    [self setupPuzzlePiecesForInteractionFromPreview:preview];
    [preview removeFromSuperview];
}

- (void)checkForCompletion
{
    NSInteger correctPieces = 0;
    for (id<SCHStoryInteractionJigsawPieceView> piece in self.jigsawPieceViews) {
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
                             completed.frame = [self puzzlePreviewFrame];
                         }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self presentNextView];
        });
    }
}

#pragma mark - play again

- (void)playAgain:(id)sender
{
    self.jigsawPaths = nil;
    [self presentNextView];
}

#pragma mark - subclass overrides

- (UIView *)newPieceViewForImage:(CGImageRef)image
{
    return nil;
}

- (CGRect)puzzlePreviewFrame
{
    return CGRectZero;
}

- (void)setupPuzzlePiecesForInteractionFromPreview:(SCHStoryInteractionJigsawPreviewView *)preview
{}

@end
