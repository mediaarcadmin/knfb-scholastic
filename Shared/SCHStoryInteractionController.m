//
//  SCHStoryInteractionController.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionTypes.h"
#import "SCHStoryInteractionControllerMultipleChoiceText.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHQueuedAudioPlayer.h"

@interface SCHStoryInteractionController ()

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, assign) NSInteger currentScreenIndex;
@property (nonatomic, retain) UILabel *titleView;
@property (nonatomic, retain) UIButton *readAloudButton;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) SCHQueuedAudioPlayer *audioPlayer;

- (UIImage *)backgroundImage;

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
@synthesize frameStyle;
@synthesize backgroundView;
@synthesize storyInteraction;
@synthesize delegate;
@synthesize interfaceOrientation;
@synthesize audioPlayer;

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
    
    [xpsProvider release];
    [containerView release];
    [titleView release], titleView = nil;
    [readAloudButton release];
    [nibObjects release];
    [contentsView release];
    [backgroundView release];
    [storyInteraction release];
    [audioPlayer release];
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

        SCHQueuedAudioPlayer *player = [[SCHQueuedAudioPlayer alloc] init];
        self.audioPlayer = player;
        [player release];
        
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
        contentInsets = UIEdgeInsetsMake((self.frameStyle == SCHStoryInteractionNoTitle ? 40 : 130), 40, 40, 40);
        titleInsets = UIEdgeInsetsMake(45, 65, 21, 65);
        closePosition = [self.storyInteraction isOlderStoryInteraction] ? CGPointMake(3, -8) : CGPointMake(9, -17);
        readAloudPosition = CGPointMake(-5, 5);
    } else {
        contentInsets = UIEdgeInsetsMake((self.frameStyle == SCHStoryInteractionNoTitle ? 5 : 70), 5, 5, 5);
        titleInsets = UIEdgeInsetsMake(5, 50, 5, 50);
        closePosition = CGPointMake(10, 7);
        readAloudPosition = CGPointMake(-13, 15);
    }
    
    UIButton *closeButton = nil;
    UIButton *audioButton = nil;
    if (self.containerView == nil) {
        self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
        
        NSString *questionAudioPath = [self audioPathForQuestion];
        [self playBundleAudioWithFilename:[storyInteraction storyInteractionOpeningSoundFilename]
                               completion:^{
                                   if (questionAudioPath && [self shouldPlayQuestionAudioForViewAtIndex:self.currentScreenIndex]) {
                                       [self playAudioAtPath:questionAudioPath completion:nil];
                                   }
                               }];
        
        // set up the transparent full-size container to trap touch events before they get
        // to the underlying view; this effectively makes the story interaction modal
        UIView *container = [[UIView alloc] initWithFrame:CGRectIntegral(hostView.bounds)];
        if (self.frameStyle != SCHStoryInteractionTitleOverlaysContents) {
            container.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        }
        container.userInteractionEnabled = YES;
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[self backgroundImage]];
        background.contentMode = UIViewContentModeScaleToFill;
        background.userInteractionEnabled = YES;
        [container addSubview:background];
       
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
        title.backgroundColor = [UIColor clearColor];
        
        BOOL hasShadow = NO;

        if (self.frameStyle != SCHStoryInteractionNoTitle) {
            if ([self.storyInteraction isOlderStoryInteraction]) {
                hasShadow = YES;
                title.font = [UIFont fontWithName:@"Arial Black" size:(iPad ? 30 : 25)];
            } else {
                title.font = [UIFont fontWithName:@"Arial-BoldMT" size:(iPad ? 22 : 17)];
            }
            
            title.textAlignment = UITextAlignmentCenter;
            title.textColor = [self.storyInteraction isOlderStoryInteraction] ? [UIColor whiteColor] : [UIColor colorWithRed:0.113 green:0.392 blue:0.690 alpha:1.];
            title.adjustsFontSizeToFitWidth = YES;
            title.numberOfLines = 2;
            if (hasShadow) {
                title.layer.shadowOpacity = 0.7f;
                title.layer.shadowRadius = 2;
                title.layer.shadowOffset = CGSizeZero;
            }
            self.titleView = title;
            [background addSubview:title];
            [title release];            
        }
        
        NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
        UIImage *closeImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bolt-%@", age]];
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.bounds = (CGRect){ CGPointZero, closeImage.size };
        closeButton.center = CGPointMake(floorf(closePosition.x+closeImage.size.width/2), floorf(closePosition.y+closeImage.size.height/2));
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:closeButton];

        if (questionAudioPath) {
            UIImage *readAloudImage = [UIImage imageNamed:@"storyinteraction-read-aloud"];
            audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    if (!iPad) {
        CGSize size = CGSizeZero;
        switch (self.frameStyle) {
            case SCHStoryInteractionFullScreen:
                size = [UIScreen mainScreen].bounds.size; 
                break;
            case SCHStoryInteractionNoTitle:
                size = CGSizeMake(315.0, 470.0);
                break;
                
            case SCHStoryInteractionTitle:
            case SCHStoryInteractionTransparentTitle:                
            default:
                size = CGSizeMake(250.0, 470.0);
                break;
        }
        if (CGRectGetWidth(newContentsView.bounds) > size.height || CGRectGetHeight(newContentsView.bounds) > size.width) {
            NSLog(@"contentView %d is too large: %@", self.currentScreenIndex, NSStringFromCGRect(newContentsView.bounds));
        }
    }

    dispatch_block_t setupGeometry = nil;
    switch (self.frameStyle) {
        case SCHStoryInteractionFullScreen:
            setupGeometry = ^{
                self.backgroundView.image = nil;
                CGSize size = [UIScreen mainScreen].bounds.size;  
                CGFloat backgroundWidth = size.height;
                CGFloat backgroundHeight = size.width;

                self.backgroundView.backgroundColor = [UIColor blackColor];
                self.backgroundView.frame = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
                newContentsView.frame = self.backgroundView.frame; 
                
                self.readAloudButton.center = CGPointMake(floorf(backgroundWidth+readAloudPosition.x-CGRectGetMidX(self.readAloudButton.bounds)),
                                                          floorf(readAloudPosition.y+CGRectGetMidX(self.readAloudButton.bounds)));
                
                self.contentsView.alpha = 0;
                newContentsView.alpha = 1;
                newContentsView.transform = CGAffineTransformIdentity;
            };
            break;
                        
        case SCHStoryInteractionTitle: 
        case SCHStoryInteractionTransparentTitle:                            
        case SCHStoryInteractionNoTitle:            
            setupGeometry = ^{
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
            break;
            
        case SCHStoryInteractionTitleOverlaysContents:
            setupGeometry = ^{
                CGRect titleFrame = [self overlaidTitleFrame];
                CGFloat backgroundWidth = MAX(backgroundView.image.size.width, titleFrame.size.width);
                CGFloat backgroundHeight = MAX(backgroundView.image.size.height, titleFrame.size.height);
                self.backgroundView.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
                self.backgroundView.center = CGPointMake(floorf(CGRectGetMidX(titleFrame)), floorf(CGRectGetMidY(titleFrame)));
                newContentsView.bounds = self.containerView.bounds;
                newContentsView.center = CGPointMake(floorf(CGRectGetMidX(self.containerView.bounds)), floorf(CGRectGetMidY(self.containerView.bounds)));
                UIEdgeInsets centredTitleInsets = titleInsets;
                centredTitleInsets.top = centredTitleInsets.bottom;
                self.titleView.frame = UIEdgeInsetsInsetRect(self.backgroundView.bounds, centredTitleInsets);
                self.readAloudButton.center = CGPointMake(floorf(backgroundWidth+readAloudPosition.x-CGRectGetMidX(self.readAloudButton.bounds)),
                                                          floorf(readAloudPosition.y+CGRectGetMidX(self.readAloudButton.bounds)));
            };
            break;
    }
    
    if (self.contentsView != nil) {
        // animate the transition between screens
        NSAssert(self.frameStyle != SCHStoryInteractionTitleOverlaysContents, @"can't have multiple views with SCHStoryInteractionTitleOverlaysContents");
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
        if (self.frameStyle == SCHStoryInteractionTitleOverlaysContents) {
            [self.backgroundView removeFromSuperview];
            [self.containerView addSubview:newContentsView];
            [newContentsView addSubview:self.backgroundView];
        } else {
            [self.backgroundView addSubview:newContentsView];
        }
    }
    
    [self.backgroundView bringSubviewToFront:closeButton];
    [self.backgroundView bringSubviewToFront:audioButton];
    
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
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
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
                         if (self.frameStyle != SCHStoryInteractionTitleOverlaysContents) {
                             self.backgroundView.center = superviewCenter;
                         }
                     }
                     completion:nil];
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
    if (self.frameStyle != SCHStoryInteractionTitleOverlaysContents) {
        self.backgroundView.center = CGPointMake(floor(CGRectGetMidX(self.containerView.bounds)), floor(CGRectGetMidY(self.containerView.bounds)));
    }
}

- (UIImage *)backgroundImage
{
    NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
    NSString *suffix;
    switch (self.frameStyle) {
        case SCHStoryInteractionNoTitle:
        case SCHStoryInteractionTransparentTitle:
            suffix = @"-notitle";
            break;
        case SCHStoryInteractionTitleOverlaysContents:
            suffix = @"-titleonly";
            break;
        default:
            suffix = @"";
            break;
    }
    
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bg-%@%@", age, suffix]];
    UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2-1
                                                                      topCapHeight:backgroundImage.size.height/2-1];
    return backgroundStretch;
}

#pragma mark - actions

- (void)closeButtonTapped:(id)sender
{
    [self removeFromHostViewWithSuccess:NO];
}

- (void)setUserInteractionsEnabled:(BOOL)enabled
{
    NSLog(@"user interactions enabled = %d", enabled);
    self.containerView.superview.userInteractionEnabled = enabled;
    self.containerView.userInteractionEnabled = enabled;
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self.audioPlayer cancel];
}

- (void)removeFromHostViewWithSuccess:(BOOL)success
{
    [self cancelQueuedAudio];
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    
    // always, always re-enable user interactions for the superview...
    [self setUserInteractionsEnabled:YES];
    
    [self.containerView removeFromSuperview];
    
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionController:didDismissWithSuccess:)]) {
        // may result in self being dealloc'ed so don't do anything else after this
        [delegate storyInteractionController:self didDismissWithSuccess:success];
    }
}

#pragma mark - Audio methods

- (IBAction)playAudioButtonTapped:(id)sender
{
    NSString *path = [self audioPathForQuestion];
    if (path != nil) {
        [self playAudioAtPath:path completion:nil];
    }   
}

- (void)playAudioAtPath:(NSString *)path completion:(void (^)(void))completion
{
    [self.audioPlayer cancel];
    [self enqueueAudioWithPath:path fromBundle:NO startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:completion];
}

- (void)playBundleAudioWithFilename:(NSString *)filename completion:(void (^)(void))completion
{
    [self.audioPlayer cancel];
    [self enqueueAudioWithPath:filename fromBundle:YES startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:completion];
}

- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock
{
    [self.audioPlayer enqueueGap:startDelay];
    
    SCHQueuedAudioPlayerFetchBlock fetchBlock;
    if (fromBundle) {
        fetchBlock = ^NSData*(void){
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:path ofType:@""];
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfFile:bundlePath options:NSDataReadingMapped error:&error];
            if (!data) {
                NSLog(@"failed to read %@: %@", bundlePath, error);
            }
            return data;
        };
    } else {
        fetchBlock = ^NSData*(void){
            return [self.xpsProvider dataForComponentAtPath:path];
        };
    }

    [self.audioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock synchronizedStartBlock:startBlock synchronizedEndBlock:endBlock];
}

- (void)enqueueAudioWithPath:(NSString *)path fromBundle:(BOOL)fromBundle
{
    [self enqueueAudioWithPath:path fromBundle:fromBundle startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:nil];
}


- (BOOL)playingAudio
{
    return [self.audioPlayer isPlaying];
}

- (void)cancelQueuedAudio
{
    [self.audioPlayer cancel];
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

- (BOOL)shouldPlayQuestionAudioForViewAtIndex:(NSInteger)screenIndex
{
    return YES;
}

- (NSString *)audioPathForQuestion
{
    return [self.storyInteraction audioPathForQuestion];
}

- (SCHFrameStyle)frameStyle
{
    return(SCHStoryInteractionTitle);
}

- (CGRect)overlaidTitleFrame
{
    return CGRectZero;
}

@end

