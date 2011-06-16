//
//  SCHStoryInteractionController.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionTypes.h"
#import "SCHStoryInteractionControllerMultipleChoiceText.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"

typedef void (^PlayAudioCompletionBlock)(void);

@interface SCHStoryInteractionController ()

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, assign) NSInteger currentScreenIndex;
@property (nonatomic, retain) UILabel *titleView;
@property (nonatomic, retain) UIButton *readAloudButton;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL resumeInterruptedPlayer;
@property (nonatomic, copy) PlayAudioCompletionBlock playAudioCompletionBlock;

@property (nonatomic, assign) dispatch_queue_t audioPlayQueue;

- (UIImage *)deviceSpecificImageNamed:(NSString *)name;
- (void)endAudio;

@end

@implementation SCHStoryInteractionController

@synthesize xpsProvider;
@synthesize isbn;
@synthesize containerView;
@synthesize titleView;
@synthesize readAloudButton;
@synthesize nibObjects;
@synthesize currentScreenIndex;
@synthesize contentsView;
@synthesize backgroundView;
@synthesize storyInteraction;
@synthesize delegate;
@synthesize player;
@synthesize resumeInterruptedPlayer;
@synthesize playAudioCompletionBlock;
@synthesize audioPlayQueue;
@synthesize interfaceOrientation;

+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    NSString *className = [NSString stringWithCString:object_getClassName(storyInteraction) encoding:NSUTF8StringEncoding];
    NSString *controllerClassName = [NSString stringWithFormat:@"%@Controller%@", [className substringToIndex:19], [className substringFromIndex:19]];
    Class controllerClass = NSClassFromString(controllerClassName);
    if (!controllerClass) {
        controllerClassName = [controllerClassName stringByAppendingString:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @"_iPhone")];
        controllerClass = NSClassFromString(controllerClassName);
        if (!controllerClass) {
            NSLog(@"Can't find controller class for %@", controllerClassName);
            return nil;
        }
    }
    return [[[controllerClass alloc] initWithStoryInteraction:storyInteraction] autorelease];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeFromHostView];
    [xpsProvider release];
    [containerView release];
    [titleView release], titleView = nil;
    [readAloudButton release];
    [nibObjects release];
    [contentsView release];
    [backgroundView release];
    [storyInteraction release];
    [player release], player = nil;
    Block_release(playAudioCompletionBlock), playAudioCompletionBlock = nil;
    dispatch_release(audioPlayQueue);
    [super dealloc];
}

- (id)initWithStoryInteraction:(SCHStoryInteraction *)aStoryInteraction
{
    if ((self = [super init])) {
        storyInteraction = [aStoryInteraction retain];

        NSString *nibName = [NSString stringWithFormat:@"%s_%s", object_getClassName(aStoryInteraction),
                             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? "iPad" : "iPhone")];
        
        self.nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        if ([self.nibObjects count] == 0) {
            NSLog(@"failed to load nib %@", nibName);
            return nil;
        }
        
        self.audioPlayQueue = dispatch_queue_create("audioPlayQueue", NULL);
        
        resumeInterruptedPlayer = NO;
        playAudioCompletionBlock = nil;
        currentScreenIndex = 0;
        
        // register for going into the background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)presentInHostView:(UIView *)hostView withInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIEdgeInsets contentInsets;
    UIEdgeInsets titleInsets;
    CGPoint closePosition;     // relative to top-left corner
    CGPoint readAloudPosition; // relative to top-right corner
    if (iPad) {
        contentInsets = UIEdgeInsetsMake(130, 40, 40, 40);
        titleInsets = UIEdgeInsetsMake(45, 65, 21, 65);
        closePosition = [self.storyInteraction isOlderStoryInteraction] ? CGPointMake(3, -8) : CGPointMake(9, -17);
        readAloudPosition = CGPointMake(-5, 5);
    } else {
        contentInsets = UIEdgeInsetsMake(70, 5, 5, 5);
        titleInsets = UIEdgeInsetsMake(5, 50, 5, 50);
        closePosition = CGPointMake(10, 7);
        readAloudPosition = CGPointMake(-13, 15);
    }
    
    if (self.containerView == nil) {
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        
        // set up the transparent full-size container to trap touch events before they get
        // to the underlying view; this effectively makes the story interaction modal
        UIView *container = [[UIView alloc] initWithFrame:CGRectIntegral(hostView.bounds)];
        container.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        container.userInteractionEnabled = YES;
        
        NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
        UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bg-%@", age]];
        UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2-1
                                                                          topCapHeight:backgroundImage.size.height/2-1];
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundStretch];
        background.contentMode = UIViewContentModeScaleToFill;
        background.userInteractionEnabled = YES;
        [container addSubview:background];
       
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:iPad ? 22 : 18];
        title.textAlignment = UITextAlignmentCenter;
        title.textColor = [self.storyInteraction isOlderStoryInteraction] ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.];
        title.adjustsFontSizeToFitWidth = YES;
        title.numberOfLines = 2;

        self.titleView = title;
        [background addSubview:title];
        [title release];
        
        UIImage *closeImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bolt-%@", age]];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.bounds = (CGRect){ CGPointZero, closeImage.size };
        closeButton.center = CGPointMake(floorf(closePosition.x+closeImage.size.width/2), floorf(closePosition.y+closeImage.size.height/2));
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:closeButton];

        if ([self useAudioButton] == YES) {
            UIImage *readAloudImage = [UIImage imageNamed:@"storyinteraction-read-aloud"];
            UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
            audioButton.bounds = (CGRect){ CGPointZero, readAloudImage.size };
            [audioButton setImage:readAloudImage forState:UIControlStateNormal];
            [audioButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:audioButton];
            self.readAloudButton = audioButton;
        }
        
        self.containerView = container;
        self.backgroundView = background;
        [container release];
        [background release];

        [hostView addSubview:self.containerView];
    }

    // put multiple views at the top-level in the nib for multi-screen interactions
    UIView *newContentsView = [self.nibObjects objectAtIndex:self.currentScreenIndex];
    if (!iPad && (CGRectGetWidth(newContentsView.bounds) > 470 || CGRectGetHeight(newContentsView.bounds) > 250)) {
        NSLog(@"contentView %d is too large: %@", self.currentScreenIndex, NSStringFromCGRect(newContentsView.bounds));
    }

    dispatch_block_t setupGeometry = ^{
        UIImage *backgroundImage = self.backgroundView.image;
        CGFloat backgroundWidth = MAX(backgroundImage.size.width, CGRectGetWidth(newContentsView.bounds) + contentInsets.left + contentInsets.right);
        CGFloat backgroundHeight = MAX(backgroundImage.size.height, CGRectGetHeight(newContentsView.bounds) + contentInsets.top + contentInsets.bottom);
        
        self.backgroundView.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
        self.backgroundView.center = CGPointMake(floorf(CGRectGetMidX(self.containerView.bounds)), floorf(CGRectGetMidY(self.containerView.bounds)));
        newContentsView.center = CGPointMake(floorf(backgroundWidth/2), floorf((backgroundHeight-contentInsets.top-contentInsets.bottom)/2+contentInsets.top));
        
        self.titleView.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, backgroundWidth, contentInsets.top), titleInsets);
        
        self.readAloudButton.center = CGPointMake(floorf(backgroundWidth+readAloudPosition.x-CGRectGetMidX(self.readAloudButton.bounds)),
                                                  floorf(readAloudPosition.y+CGRectGetMidX(self.readAloudButton.bounds)));
        
        self.contentsView.alpha = 0;
        newContentsView.alpha = 1;
        newContentsView.transform = CGAffineTransformIdentity;
    };

    if (self.contentsView != nil) {
        // animate the transition between screens
        UIView *oldContentsView = self.contentsView;
        newContentsView.alpha = 0;
        newContentsView.transform = CGAffineTransformMakeScale(CGRectGetWidth(oldContentsView.bounds)/CGRectGetWidth(newContentsView.bounds),
                                                               CGRectGetHeight(oldContentsView.bounds)/CGRectGetHeight(newContentsView.bounds));
        newContentsView.center = oldContentsView.center;
        [self.backgroundView addSubview:newContentsView];
        [UIView animateWithDuration:0.3
                         animations:setupGeometry
                         completion:^(BOOL finished) {
                             [oldContentsView removeFromSuperview];
                         }];
    } else {
        setupGeometry();
        [self.backgroundView addSubview:newContentsView];
    }
    
    self.contentsView = newContentsView;
    [self setTitle:[self.storyInteraction interactionViewTitle]];

    [self setupViewAtIndex:self.currentScreenIndex];
    [self didRotateToInterfaceOrientation:aInterfaceOrientation];
}

- (void)presentNextView
{
    UIView *host = [self.containerView superview];
    self.currentScreenIndex = (self.currentScreenIndex + 1) % [self.nibObjects count];
    [self presentInHostView:host withInterfaceOrientation:self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (!self.containerView.superview) {
        return;
    }
    
    CGFloat superviewWidth = CGRectGetWidth(self.containerView.superview.bounds);
    CGFloat superviewHeight = CGRectGetHeight(self.containerView.superview.bounds);
    CGRect superviewBounds = CGRectMake(0, 0, MAX(superviewWidth, superviewHeight), MIN(superviewWidth, superviewHeight));
    CGPoint superviewCenter = CGPointMake(floorf(CGRectGetMidX(superviewBounds)), floorf(CGRectGetMidY(superviewBounds)));

    [UIView animateWithDuration:duration
                     animations:^{
                         if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                             self.containerView.transform = CGAffineTransformIdentity;
                             self.containerView.center = superviewCenter;
                         }
                         if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                             CGFloat portraitOffset = (superviewWidth - superviewHeight)/2;
                             self.containerView.transform = CGAffineTransformMakeRotation(-M_PI/2);
                             self.containerView.center = CGPointMake(superviewCenter.x-portraitOffset, superviewCenter.y+portraitOffset);
                         }
                         self.containerView.bounds = CGRectIntegral(superviewBounds);
                         self.backgroundView.center = superviewCenter;
                     }];
}

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)aToInterfaceOrientation
{
    self.interfaceOrientation = aToInterfaceOrientation;
    if (!self.containerView.superview) {
        return;
    }
    CGRect superviewBounds = self.containerView.superview.bounds;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.containerView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        self.containerView.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetHeight(superviewBounds), CGRectGetWidth(superviewBounds)));
    } else {
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.bounds = CGRectIntegral(self.containerView.superview.bounds);
    }
    self.containerView.center = CGPointMake(floor(CGRectGetMidX(superviewBounds)), floor(CGRectGetMidY(superviewBounds)));
    self.backgroundView.center = CGPointMake(floor(CGRectGetMidX(self.containerView.bounds)), floor(CGRectGetMidY(self.containerView.bounds)));
}

- (void)closeButtonTapped:(id)sender
{
    [self removeFromHostView];
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self endAudio];
}

- (void)removeFromHostView
{
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    [self.containerView removeFromSuperview];
    
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionControllerDidDismiss:)]) {
        // may result in self being dealloc'ed so don't do anything else after this
        [delegate storyInteractionControllerDidDismiss:self];
    }
    
}

- (UIImage *)deviceSpecificImageNamed:(NSString *)name
{
    // most images have device-specific versions
    UIImage *image = [UIImage imageNamed:[name stringByAppendingString:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"-iphone" : @"-ipad")]];
    if (!image) {
        // not found; look for a common image
        image = [UIImage imageNamed:name];
    }
    return image;
}

#pragma mark - Audio methods

- (BOOL)useAudioButton
{
    return([self.storyInteraction isOlderStoryInteraction] == NO); 
}

- (IBAction)playAudioButtonTapped:(id)sender
{
    NSString *path = [self audioPath];
    if (path != nil) {
        [self playAudioAtPath:path completion:nil];
    }   
}

- (void)playAudioAtPath:(NSString *)path completion:(void (^)(void))completion
{
    if (self.player != nil) {
        [self endAudio];
    }
    
    __block BOOL failed = YES;

    dispatch_sync(self.audioPlayQueue, ^{
        
        NSError *error = nil;
        NSData *audioData = [self.xpsProvider dataForComponentAtPath:path];
        if (audioData != nil) {
            
            self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
            if (self.player != nil) {
                self.resumeInterruptedPlayer = NO;
                [self.player release];
                self.player.delegate = self;
                self.playAudioCompletionBlock = completion;
                [self.player play];
                failed = NO;
            }       
        }
        
    });

    // if something goes wrong we should do completion
    if(failed == YES && completion != nil) {
        completion();
    }

}

- (void)playBundleAudioWithFilename:(NSString *)path completion:(void (^)(void))completion
{
    if (self.player != nil) {
        [self endAudio];
    }
    
    __block BOOL failed = YES;

    dispatch_sync(self.audioPlayQueue, ^{
        NSError *error = nil;
        
        NSArray *pathComponents = [path componentsSeparatedByString:@"."];
        
        if (pathComponents && [pathComponents count] == 2) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[pathComponents objectAtIndex:0] ofType:[pathComponents objectAtIndex:1]];
            
            NSData *audioData = [NSData dataWithContentsOfFile:bundlePath options:NSDataReadingMapped error:nil];
            if (audioData != nil) {
                
                self.player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
                if (self.player != nil) {
                    self.resumeInterruptedPlayer = NO;
                    [self.player release];
                    self.player.delegate = self;
                    self.playAudioCompletionBlock = completion;
                    [self.player play];
                    failed = NO;
                }       
            }
        }
        
    });

    // if something goes wrong we should do completion
    if (failed == YES && completion != nil) {
        completion();
    }
}

- (BOOL)playingAudio
{
    if (self.player) {
        return YES;
    } else {
        return NO;
    }
}

- (void)endAudio
{
    self.player = nil;
    if (self.playAudioCompletionBlock != nil) {
        void (^completionBlock)(void) = [self.playAudioCompletionBlock retain];
        self.playAudioCompletionBlock = nil;
        completionBlock();
        [completionBlock release];
    }
}

#pragma mark - AVAudioPlayer Delegate methods

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.player.playing == YES) {
        [self.player pause];
        self.resumeInterruptedPlayer = YES;
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    if (self.resumeInterruptedPlayer == YES) {
        self.resumeInterruptedPlayer = NO;
        [self.player play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self endAudio];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self endAudio];    
    
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil]; 
    [errorAlert show]; 
    [errorAlert release]; 
}

#pragma mark - XPSProvider accessors

- (UIImage *)imageAtPath:(NSString *)path
{
    NSData *imageData = [self.xpsProvider dataForComponentAtPath:path];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

#pragma mark - Story Interaction accessors

- (void)setTitle:(NSString *)title
{
    self.titleView.text = title;
}

#pragma mark - subclass overrides

- (void)setupViewAtIndex:(NSInteger)screenIndex
{}

- (NSString *)audioPath
{
    return(nil);
}

@end
