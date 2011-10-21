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

enum {
    kTileGap = 5,
    kBorderWidth = 2,
    kCornerRadius = 8,
};

@interface SCHStoryInteractionControllerConcentration ()

@property (nonatomic, assign) NSInteger numberOfPairs;
@property (nonatomic, assign) NSInteger numberOfPairsFound;
@property (nonatomic, assign) NSInteger numberOfFlips;
@property (nonatomic, assign) UIView *firstFlippedTile;

- (void)setupPuzzleView;
- (UIImage *)tileBackground;
- (UIColor *)tileBorderColor;
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
    switch (index) {
        case 0:
            [self enqueueAudioWithPath:[(SCHStoryInteractionConcentration *)self.storyInteraction audioPathForIntroduction] fromBundle:NO];
            break;
        case 1:
            [self setupPuzzleView];
            break;
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
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    self.numberOfPairs = [(UIView *)sender tag];
    [self presentNextView];
}

#pragma mark - Puzzle view

- (CALayer *)layerWithImage:(UIImage *)image inSize:(CGSize)size
{
    CALayer *layer = [CALayer layer];
    layer.bounds = (CGRect){CGPointZero, size};
    layer.contents = (id)[image CGImage];
    layer.contentsGravity = kCAGravityResizeAspect;
    layer.doubleSided = NO;

    layer.borderWidth = kBorderWidth;
    layer.borderColor = [[self tileBorderColor] CGColor];
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
    CGFloat maxTileWidth = floorf((CGRectGetWidth(self.flipContainer.bounds)-(cols+1)*kTileGap-cols*2*kBorderWidth) / cols);
    CGFloat maxTileHeight = floorf((CGRectGetHeight(self.flipContainer.bounds)-(rows+1)*kTileGap-rows*2*kBorderWidth) / rows);
    CGFloat maxTileSize = MIN(maxTileWidth, maxTileHeight);
    
    UIImage *tileBackImage = [self tileBackground];
    CGSize tileSize = CGSizeMake(MIN(maxTileSize, tileBackImage.size.width)+kBorderWidth*2,
                                 MIN(maxTileSize, tileBackImage.size.height)+kBorderWidth*2);
    
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
    self.firstFlippedTile = nil;
}

- (UIImage *)tileBackground
{
    switch (self.numberOfPairs) {
        case  6: return [UIImage imageNamed:@"storyinteraction-concentration-tile-blue.png"];
        case  9: return [UIImage imageNamed:@"storyinteraction-concentration-tile-purple.png"];
        case 12: return [UIImage imageNamed:@"storyinteraction-concentration-tile-orange.png"];
    }
    return nil;
}

- (UIColor *)tileBorderColor
{
    switch (self.numberOfPairs) {
        case  6: return [UIColor SCHLightBlue2Color];
        case  9: return [UIColor SCHPurple1Color];
        case 12: return [UIColor SCHOrange1Color];
    }
    return nil;
}

- (void)setNumberOfFlips:(NSInteger)newNumberOfFlips
{
    numberOfFlips = newNumberOfFlips;
    [self.flipCounterLabel setTitle:[NSString stringWithFormat:@"%d FLIP%s", numberOfFlips, (numberOfFlips == 1 ? "" : "S")] forState:UIControlStateNormal];
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
    
    BOOL pair = (self.firstFlippedTile != nil);
    if (!pair) {
        self.firstFlippedTile = tile;
    }
    self.controllerState = SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause;
    
    CAAnimation *flip = [self flipAnimationFrom:0 to:M_PI];
    flip.delegate = [SCHAnimationDelegate animationDelegateWithStopBlock:^(CAAnimation *animation, BOOL finished) {
        if (pair) {
            [self matchTile:self.firstFlippedTile withTile:tile];
            self.firstFlippedTile = nil;
        } else {
            self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
        }
    }];
    
    [tile.layer addAnimation:flip forKey:@"flip"];
    tile.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);

    [self enqueueAudioWithPath:@"sfx_dropOK.mp3" fromBundle:YES];

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
            self.controllerState = SCHStoryInteractionControllerStateInteractionFinishedSuccessfully;
            [self setUserInteractionsEnabled:NO];
            [self enqueueAudioWithPath:@"sfx_win_y.mp3" fromBundle:YES];
            [self enqueueAudioWithPath:[(SCHStoryInteractionConcentration *)self.storyInteraction audioPathForYouWon]
                            fromBundle:NO
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      [self removeFromHostView];
                  }];
        }
        self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // flip the tiles back
            [tile1.layer addAnimation:[self flipAnimationFrom:M_PI to:0] forKey:@"flipBack"];
            [tile2.layer addAnimation:[self flipAnimationFrom:M_PI to:0] forKey:@"flipBack"];
            tile1.layer.transform = CATransform3DIdentity;
            tile2.layer.transform = CATransform3DIdentity;
            [self enqueueAudioWithPath:[self.storyInteraction storyInteractionWrongAnswerSoundFilename]
                            fromBundle:YES
                            startDelay:0
                synchronizedStartBlock:nil
                  synchronizedEndBlock:^{
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }];
        });
    }
}

@end
