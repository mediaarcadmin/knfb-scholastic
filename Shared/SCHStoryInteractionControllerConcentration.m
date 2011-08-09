//
//  SCHStoryInteractionControllerConcentration.m
//  Scholastic
//
//  Created by Neil Gall on 08/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionControllerConcentration.h"
#import "SCHStoryInteractionConcentration.h"
#import "SCHAnimationDelegate.h"
#import "SCH3DView.h"
#import "UIColor+Scholastic.h"
#import "NSArray+Shuffling.h"

#define kTileGap 5
#define kBorderWidth 2
#define kCornerRadius 8

@interface SCHStoryInteractionControllerConcentration ()

@property (nonatomic, assign) NSInteger numberOfPairs;
@property (nonatomic, assign) NSInteger numberOfPairsFound;
@property (nonatomic, assign) NSInteger numberOfFlips;
@property (nonatomic, assign) UIView *firstFlippedTile;

- (void)setupPuzzleView;
- (void)matchTile:(UIView *)tile withTile:(UIView *)tile;

@end

@implementation SCHStoryInteractionControllerConcentration

@synthesize levelButtons;
@synthesize flipContainer;
@synthesize flipCounterLabel;
@synthesize startOverButton;
@synthesize numberOfPairs;
@synthesize numberOfPairsFound;
@synthesize numberOfFlips;
@synthesize firstFlippedTile;

- (void)dealloc
{
    [levelButtons release], levelButtons = nil;
    [flipContainer release], flipContainer = nil;
    [flipCounterLabel release], flipCounterLabel = nil;
    [startOverButton release], startOverButton = nil;
    [super dealloc];
}

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    return screenIndex == 1;
}

- (void)setupViewAtIndex:(NSInteger)index
{
    if (index == 1) {
        [self setupPuzzleView];
    }
}

- (void)storyInteractionDisableUserInteraction
{
    self.flipContainer.userInteractionEnabled = NO;
    self.startOverButton.userInteractionEnabled = NO;
}

- (void)storyInteractionEnableUserInteraction
{
    self.flipContainer.userInteractionEnabled = YES;
    self.startOverButton.userInteractionEnabled = YES;
}

#pragma mark - Difficulty selection

- (void)levelButtonTapped:(id)sender
{
    self.numberOfPairs = [(UIView *)sender tag];
    [self presentNextView];
}

#pragma mark - Puzzle view

- (CALayer *)layerWithImage:(UIImage *)image inSize:(CGSize)size
{
    CALayer *layer = [CALayer layer];
    layer.bounds = (CGRect){CGPointZero, size};
    layer.contents = (id)[image CGImage];
    layer.contentsGravity = kCAGravityCenter;
    layer.doubleSided = NO;

    layer.borderWidth = kBorderWidth;
    layer.borderColor = [[UIColor SCHOrange1Color] CGColor];
    layer.cornerRadius = kCornerRadius;
    layer.masksToBounds = YES;
    layer.backgroundColor = layer.borderColor;

    return layer;
}

- (void)setupPuzzleView
{
    SCHStoryInteractionConcentration *concentration = (SCHStoryInteractionConcentration *)self.storyInteraction;
    
    [self setTitle:[concentration introduction]];
    
    // enable perspective on the flip container
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = 1.0 / -2000;
    self.flipContainer.layer.sublayerTransform = sublayerTransform;

    // lay out the pieces
    NSInteger cols = MIN(6, (self.numberOfPairs*2)/3);
    NSInteger rows = (self.numberOfPairs*2)/cols;
    NSAssert(rows*cols == self.numberOfPairs*2, @"invalid factorisation of numberOfPairs");
    
    // TODO different tiles for each level
    UIImage *tileBackImage = [UIImage imageNamed:@"storyinteraction-concentration-tile-orange.png"];
    CGSize tileSize = CGSizeMake(tileBackImage.size.width+kBorderWidth*2, tileBackImage.size.height+kBorderWidth*2);
    
    CGSize layoutSize = CGSizeMake(tileSize.width*cols + kTileGap*(cols-1),
                                   tileSize.height*rows + kTileGap*(rows-1));
    CGSize containerSize = self.flipContainer.bounds.size;
    CGFloat left = (containerSize.width-layoutSize.width)/2;
    CGFloat top = (containerSize.height-layoutSize.height)/2;
    CGPoint layerPosition = CGPointMake(floorf(tileSize.width/2), floorf(tileSize.height/2));
    
    NSMutableArray *indices = [NSMutableArray arrayWithCapacity:self.numberOfPairs*2];
    for (NSInteger i = 0; i < self.numberOfPairs*2; ++i) {
        [indices addObject:[NSNumber numberWithInteger:i]];
    }
    NSArray *shuffledIndices = [indices shuffled];
    
    for (NSInteger row = 0; row < rows; ++row) {
        for (NSInteger col = 0; col < cols; ++col) {
            NSInteger index = [[shuffledIndices objectAtIndex:row*cols+col] integerValue];
            UIImage *image;
            if (index & 1) {
                image = [self imageAtPath:[concentration imagePathForSecondOfPairAtIndex:index/2]];
            } else {
                image = [self imageAtPath:[concentration imagePathForFirstOfPairAtIndex:index/2]];
            }
            NSAssert(image != nil, @"didn't find image at index %d", index);
            
            SCH3DView *tile = [[SCH3DView alloc] initWithFrame:CGRectZero];
            tile.backgroundColor = [UIColor clearColor];
            tile.bounds = (CGRect){ CGPointZero, tileSize };
            tile.center = CGPointMake(floorf(left+(tileSize.width+kTileGap)*col+tileSize.width/2),
                                      floorf(top+(tileSize.height+kTileGap)*row+tileSize.height/2));
            tile.tag = index/2;

            CALayer *back = [self layerWithImage:tileBackImage inSize:tileSize];
            back.position = layerPosition;
            [tile.layer addSublayer:back];
            
            CALayer *front = [self layerWithImage:image inSize:tileSize];
            front.position = layerPosition;
            front.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            [tile.layer addSublayer:front];
            
            [self.flipContainer addSubview:tile];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tileTapped:)];
            [tile addGestureRecognizer:tap];
            [tap release];
            [tile release];
        }
    }
    
    self.numberOfPairsFound = 0;
    self.numberOfFlips = 0;
}

- (void)setNumberOfFlips:(NSInteger)newNumberOfFlips
{
    numberOfFlips = newNumberOfFlips;
    self.flipCounterLabel.text = [NSString stringWithFormat:@"%d FLIPS", numberOfFlips];
}

- (void)startOverTapped:(id)sender
{
    [self.flipContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self presentNextView];
}

- (CAAnimation *)flipAnimationFrom:(CGFloat)fromAngle to:(CGFloat)toAngle
{
    CABasicAnimation *flip = [CABasicAnimation animationWithKeyPath:@"transform"];
    flip.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(fromAngle, 0, 1, 0)];
    flip.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(toAngle, 0, 1, 0)];
    flip.duration = 0.3;
    return flip;
}

- (void)tileTapped:(UITapGestureRecognizer *)tap
{
    UIView *tile = tap.view;
    if (tile == self.firstFlippedTile) {
        return;
    }
    
    BOOL match = (self.firstFlippedTile != nil);
    if (!match) {
        self.firstFlippedTile = tile;
    }
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
    
    CAAnimation *flip = [self flipAnimationFrom:0 to:M_PI];
    flip.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        if (match) {
            [self matchTile:self.firstFlippedTile withTile:tile];
            self.firstFlippedTile = nil;
        } else {
            self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
        }
    }];
    
    [tile.layer addAnimation:flip forKey:@"flip"];
    tile.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);

    self.numberOfFlips++;
}

- (void)matchTile:(UIView *)tile1 withTile:(UIView *)tile2
{
    if (tile1.tag == tile2.tag) {
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename]
                        fromBundle:YES];
        [tile1 setUserInteractionEnabled:NO];
        [tile2 setUserInteractionEnabled:NO];
        if (++self.numberOfPairsFound == self.numberOfPairs) {
            [self enqueueAudioWithPath:[(SCHStoryInteractionConcentration *)self.storyInteraction audioPathForYouGotThemAll]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
                      [self removeFromHostView];
                  }];
        }
        self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    } else {
        // flip the tiles back
        [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                        fromBundle:YES
                        startDelay:0
         synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  [tile1.layer addAnimation:[self flipAnimationFrom:M_PI to:0] forKey:@"flipBack"];
                  [tile2.layer addAnimation:[self flipAnimationFrom:M_PI to:0] forKey:@"flipBack"];
                  tile1.layer.transform = CATransform3DIdentity;
                  tile2.layer.transform = CATransform3DIdentity;
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }];
    }
}

@end
