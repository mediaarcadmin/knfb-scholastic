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

static NSUInteger const kSCHStoryInteractionControllerButtonSize = 30;

typedef void (^PlayAudioCompletionBlock)(void);

@interface SCHStoryInteractionController ()

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, assign) NSInteger currentScreenIndex;
@property (nonatomic, retain) UILabel *titleView;
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
    if (self.containerView == nil) {
        
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

        UIEdgeInsets contentInsets;
        UIEdgeInsets titleInsets;
        if (iPad) {
            contentInsets = UIEdgeInsetsMake(130, 40, 40, 40);
            titleInsets = UIEdgeInsetsMake(40, 40, 26, 40);
        } else {
            contentInsets = UIEdgeInsetsMake(70, 5, 5, 5);
            titleInsets = UIEdgeInsetsMake(5, 30, 5, 30);
        }
        
        // set up the transparent full-size container to trap touch events before they get
        // to the underlying view; this effectively makes the story interaction modal
        UIView *container = [[UIView alloc] initWithFrame:CGRectIntegral(hostView.bounds)];
        container.backgroundColor = [UIColor clearColor];
        container.userInteractionEnabled = YES;
        
        NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
        UIImage *backgroundImage = [self deviceSpecificImageNamed:[NSString stringWithFormat:@"storyinteraction-bg-%@", age]];
        UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2-1
                                                                          topCapHeight:backgroundImage.size.height/2-1];
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundStretch];
        background.contentMode = UIViewContentModeScaleToFill;
        
        // first object in the NIB must be the container view for the interaction
        self.contentsView = [self.nibObjects objectAtIndex:self.currentScreenIndex];
        if (!iPad && (CGRectGetWidth(self.contentsView.bounds) > 470 || CGRectGetHeight(self.contentsView.bounds) > 250)) {
            NSLog(@"contentView %d is too large: %@", self.currentScreenIndex, NSStringFromCGRect(self.contentsView.bounds));
        }
        
        CGFloat backgroundWidth = CGRectGetWidth(self.contentsView.bounds) + contentInsets.left + contentInsets.right;
        CGFloat backgroundHeight = CGRectGetHeight(self.contentsView.bounds) + contentInsets.top + contentInsets.bottom;
        
        background.userInteractionEnabled = YES;
        background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
        background.center = CGPointMake(floor(CGRectGetMidX(container.bounds)), floor(CGRectGetMidY(container.bounds)));
        self.contentsView.center = CGPointMake(floor(backgroundWidth/2), floor((backgroundHeight-contentInsets.top-contentInsets.bottom)/2+contentInsets.top));
        [background addSubview:self.contentsView];
        [container addSubview:background];
        
        CGRect titleFrame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, backgroundWidth, contentInsets.top), titleInsets);
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectIntegral(titleFrame)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:iPad ? 24 : 18];
        title.textAlignment = UITextAlignmentCenter;
        title.textColor = [self.storyInteraction isOlderStoryInteraction] ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.];
        title.adjustsFontSizeToFitWidth = YES;
        title.numberOfLines = 2;

        self.titleView = title;
        [self setTitle:[self.storyInteraction interactionViewTitle]];
        [background addSubview:title];
        [title release];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (iPad) {
            closeButton.frame = CGRectMake(-10, -10, kSCHStoryInteractionControllerButtonSize, kSCHStoryInteractionControllerButtonSize);
        } else {
            closeButton.frame = CGRectMake(5, 5, kSCHStoryInteractionControllerButtonSize, kSCHStoryInteractionControllerButtonSize);
        }
        [closeButton setImage:[UIImage imageNamed:@"storyinteraction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:closeButton];

        if ([self useAudioButton] == YES) {
            UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
            audioButton.frame = iPad ? CGRectMake(backgroundWidth-20, -10, kSCHStoryInteractionControllerButtonSize, kSCHStoryInteractionControllerButtonSize) : 
            CGRectMake(backgroundWidth-35, 5, kSCHStoryInteractionControllerButtonSize, kSCHStoryInteractionControllerButtonSize);
            [audioButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
            [audioButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:audioButton];
        }
        
        self.containerView = container;
        self.backgroundView = background;
        [container release];
        [background release];

        [self setupViewAtIndex:self.currentScreenIndex];
    }
    
    [hostView addSubview:self.containerView];
    [self didRotateToInterfaceOrientation:aInterfaceOrientation];
}

- (void)presentNextView
{
    UIView *host = [self.containerView superview];
    self.currentScreenIndex = (self.currentScreenIndex + 1) % [self.nibObjects count];
    [self.containerView removeFromSuperview];
    self.containerView = nil;
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
    [self removeFromHostViewWithSuccess:NO];
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self endAudio];
}

- (void)removeFromHostView
{
    [self removeFromHostViewWithSuccess:YES];
}

- (void)removeFromHostViewWithSuccess:(BOOL)success
{
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    [self.containerView removeFromSuperview];
    
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionController:didDismissWithSuccess:)]) {
        // may result in self being dealloc'ed so don't do anything else after this
        [delegate storyInteractionController:self didDismissWithSuccess:success];
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
