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

#define kBackgroundLeftCap 10
#define kBackgroundTopCap_iPhone 40
#define kBackgroundTopCap_iPad 50
#define kContentsInsetLeft 5
#define kContentsInsetRight 5
#define kContentsInsetTop_iPhone 36
#define kContentsInsetTop_iPad 46
#define kContentsInsetBottom 5
#define kTitleInsetLeft 10
#define kTitleInsetTop 5

typedef void (^PlayAudioCompletionBlock)(void);

@interface SCHStoryInteractionController ()

@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, retain) UIView *contentsView;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL resumeInterruptedPlayer;
@property (nonatomic, copy) PlayAudioCompletionBlock playAudioCompletionBlock;

- (UIImage *)deviceSpecificImageNamed:(NSString *)name;
- (void)updateOrientation;
- (void)endAudio;

@end

@implementation SCHStoryInteractionController

@synthesize xpsProvider;
@synthesize isbn;
@synthesize containerView;
@synthesize nibObjects;
@synthesize contentsView;
@synthesize backgroundView;
@synthesize storyInteraction;
@synthesize delegate;
@synthesize interfaceOrientation;
@synthesize player;
@synthesize resumeInterruptedPlayer;
@synthesize playAudioCompletionBlock;

+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    NSString *className = [NSString stringWithCString:object_getClassName(storyInteraction) encoding:NSUTF8StringEncoding];
    NSString *controllerClassName = [NSString stringWithFormat:@"%@Controller%@", [className substringToIndex:19], [className substringFromIndex:19]];
    Class controllerClass = NSClassFromString(controllerClassName);
    if (!controllerClass) {
        NSLog(@"Can't find controller class for %@", controllerClassName);
        return nil;
    }
    return [[[controllerClass alloc] initWithStoryInteraction:storyInteraction] autorelease];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeFromHostView];
    [xpsProvider release];
    [containerView release];
    [nibObjects release];
    [contentsView release];
    [backgroundView release];
    [storyInteraction release];
    [player release], player = nil;
    Block_release(playAudioCompletionBlock), playAudioCompletionBlock = nil;
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
        
        resumeInterruptedPlayer = NO;
        playAudioCompletionBlock = nil;
        
        // register for going into the background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)presentInHostView:(UIView *)hostView
{
    if (self.containerView == nil) {
        
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        
        BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        
        int kBackgroundTopCap, kContentsInsetTop;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            kBackgroundTopCap = kBackgroundTopCap_iPhone;
            kContentsInsetTop = kContentsInsetTop_iPhone;
        } else {
            kBackgroundTopCap = kBackgroundTopCap_iPad;
            kContentsInsetTop = kContentsInsetTop_iPad;
        }

        // set up the transparent full-size container to trap touch events before they get
        // to the underlying view; this effectively makes the story interaction modal
        UIView *container = [[UIView alloc] initWithFrame:CGRectIntegral(hostView.bounds)];
        container.backgroundColor = [UIColor clearColor];
        container.userInteractionEnabled = YES;
        
        NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
        UIImage *backgroundImage = [self deviceSpecificImageNamed:[NSString stringWithFormat:@"storyinteraction-bg-%@", age]];
        UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:kBackgroundLeftCap topCapHeight:kBackgroundTopCap];
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundStretch];
        
        // first object in the NIB must be the container view for the interaction
        self.contentsView = [self.nibObjects objectAtIndex:0];
        CGFloat backgroundWidth = MIN(CGRectGetWidth(self.contentsView.bounds) + kContentsInsetLeft + kContentsInsetRight, CGRectGetWidth(hostView.bounds));
        CGFloat backgroundHeight = MIN(CGRectGetHeight(self.contentsView.bounds) + kContentsInsetTop + kContentsInsetBottom, CGRectGetHeight(hostView.bounds));
        
        background.userInteractionEnabled = YES;
        background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
        background.center = CGPointMake(floor(CGRectGetMidX(container.bounds)), floor(CGRectGetMidY(container.bounds)));
        self.contentsView.center = CGPointMake(floor(backgroundWidth/2), floor((backgroundHeight-kContentsInsetTop-kContentsInsetBottom)/2+kContentsInsetTop));
        [background addSubview:self.contentsView];
        [container addSubview:background];
        
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(kTitleInsetLeft, kTitleInsetTop,
                                                                                      backgroundWidth - kTitleInsetLeft*2,
                                                                                      kContentsInsetTop - kTitleInsetTop*2))];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:iPad ? 24 : 18];
        titleView.text = [self.storyInteraction interactionViewTitle];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.textColor = iPad ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.];
        titleView.adjustsFontSizeToFitWidth = YES;
        [background addSubview:titleView];
        [titleView release];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(-10, -10, 30, 30);
        [closeButton setImage:[UIImage imageNamed:@"storyinteraction-close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:closeButton];

        if ([self.storyInteraction isOlderStoryInteraction] == NO) {
            UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
            audioButton.frame = CGRectMake(backgroundWidth - 20, -10, 30, 30);
            [audioButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
            [audioButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:audioButton];
        }
        
        self.containerView = container;
        self.backgroundView = background;
        [container release];
        [background release];

        // any other views in the nib are added to the title bar
        NSInteger x = backgroundWidth - kContentsInsetRight;
        for (NSUInteger i = [self.nibObjects count]-1; i > 0; --i) {
            UIView *view = [self.nibObjects objectAtIndex:i];
            CGRect viewFrame = view.frame;
            viewFrame.origin.x = floor(x - viewFrame.size.width);
            viewFrame.origin.y = floor((kContentsInsetTop - viewFrame.size.height) / 2);
            view.frame = viewFrame;
            [self.backgroundView addSubview:view];
            x -= viewFrame.size.width + 5;
        }
        
        [self setupView];
    }
    
    [hostView addSubview:self.containerView];
    [self updateOrientation];
}

- (void)updateOrientation
{
    if (!self.containerView.superview) {
        return;
    }
    CGRect superviewBounds = self.containerView.superview.bounds;
    BOOL rotate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        rotate = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    } else {
        rotate = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    }
    if (rotate) {
        self.containerView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        self.containerView.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetHeight(superviewBounds), CGRectGetWidth(superviewBounds)));
    } else {
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.bounds = CGRectIntegral(self.containerView.superview.bounds);
    }
    self.containerView.center = CGPointMake(floor(CGRectGetMidX(superviewBounds)), floor(CGRectGetMidY(superviewBounds)));
    self.backgroundView.center = CGPointMake(floor(CGRectGetMidX(self.containerView.bounds)), floor(CGRectGetMidY(self.containerView.bounds)));

    NSLog(@"hostView.center = %@ .bounds = %@", NSStringFromCGPoint(self.containerView.superview.center), NSStringFromCGRect(superviewBounds));
    NSLog(@"containerView.center = %@ .bounds = %@", NSStringFromCGPoint(self.containerView.center), NSStringFromCGRect(self.containerView.bounds));
    NSLog(@"backgroundView.center = %@ .bounds = %@", NSStringFromCGPoint(self.backgroundView.center), NSStringFromCGRect(self.backgroundView.bounds));
    NSLog(@"contentsView.center = %@ .bounds = %@", NSStringFromCGPoint(self.contentsView.center), NSStringFromCGRect(self.contentsView.bounds));
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    interfaceOrientation = aInterfaceOrientation;
    [self updateOrientation];
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

#pragma mark - XPSProvider accessors

- (void)playAudioAtPath:(NSString *)path completion:(void (^)(void))completion
{
    NSError *error = nil;
    BOOL failed = YES;
    
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
    
    // if something goes wrong we should do completion
    if(failed == YES && completion != nil) {
        completion();
    }
}

- (void)endAudio
{
    self.player = nil;
    if (self.playAudioCompletionBlock != nil) {
        self.playAudioCompletionBlock();
        self.playAudioCompletionBlock = nil;
    }
}

- (UIImage *)imageAtPath:(NSString *)path
{
    NSData *imageData = [self.xpsProvider dataForComponentAtPath:path];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
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

#pragma mark - subclass overrides

- (void)setupView
{}

- (IBAction)playAudioButtonTapped:(id)sender
{
}

@end
