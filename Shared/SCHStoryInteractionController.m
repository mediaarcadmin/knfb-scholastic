//
//  SCHStoryInteractionController.m
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

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
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIButton *readAloudButton;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) SCHQueuedAudioPlayer *audioPlayer;
@property (nonatomic, retain) UIView *shadeView;

- (void)setupGeometryForContentsView:(UIView *)contents contentsSize:(CGSize)contentsSize;
- (CGSize)maximumContentsSize;
- (UIImage *)backgroundImage;

@end

@implementation SCHStoryInteractionController

@synthesize xpsProvider;
@synthesize bookIdentifier;
@synthesize containerView;
@synthesize titleView;
@synthesize closeButton;
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
@synthesize shadeView;
@synthesize controllerState;

static Class controllerClassForStoryInteraction(SCHStoryInteraction *storyInteraction)
{
    Class storyInteractionClass = object_getClass(storyInteraction);
    do {
        // only evaluate SCH- classes
        NSString *className = [NSString stringWithCString:class_getName(storyInteractionClass) encoding:NSUTF8StringEncoding];
        if (![[className substringToIndex:3] isEqualToString:@"SCH"]) {
            return nil;
        }
        NSString *controllerClassName = [NSString stringWithFormat:@"%@Controller%@", [className substringToIndex:19], [className substringFromIndex:19]];
        Class controllerClass = NSClassFromString(controllerClassName);
        if (controllerClass) {
            return controllerClass;
        }
        controllerClassName = [controllerClassName stringByAppendingString:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @"_iPhone")];
        controllerClass = NSClassFromString(controllerClassName);
        if (controllerClass) {
            return controllerClass;
        }
        
        storyInteractionClass = class_getSuperclass(storyInteractionClass);
    }
    while (storyInteractionClass != nil);
    return nil;
}

+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    Class controllerClass = controllerClassForStoryInteraction(storyInteraction);
    if (!controllerClass) {
        NSLog(@"Can't find controller class for %@", object_getClassName(storyInteraction));
        return nil;
    }
    return [[[controllerClass alloc] initWithStoryInteraction:storyInteraction] autorelease];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [xpsProvider release], xpsProvider = nil;
    [containerView release], containerView = nil;
    [titleView release], titleView = nil;
    [closeButton release], closeButton = nil;
    [readAloudButton release], readAloudButton = nil;
    [nibObjects release], nibObjects = nil;
    [contentsView release], contentsView = nil;
    [backgroundView release], backgroundView = nil;
    [storyInteraction release], storyInteraction = nil;
    [audioPlayer release], audioPlayer = nil;
    [shadeView release], shadeView = nil;
    [super dealloc];
}

- (id)initWithStoryInteraction:(SCHStoryInteraction *)aStoryInteraction
{
    if ((self = [super init])) {
        storyInteraction = [aStoryInteraction retain];
        
        NSString *controllerClass = [NSString stringWithCString:object_getClassName(self) encoding:NSUTF8StringEncoding];
        NSString *prefix = [controllerClass stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
        NSString *suffix = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @"_iPhone");
        prefix = [prefix stringByReplacingOccurrencesOfString:suffix withString:@""];
        
        NSString *nibName = [NSString stringWithFormat:@"%@%@", prefix, suffix];
        self.nibObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        if ([self.nibObjects count] == 0) {
            NSLog(@"failed to load nib %@", nibName);
            return nil;
        }
        
        SCHQueuedAudioPlayer *player = [[SCHQueuedAudioPlayer alloc] init];
        self.audioPlayer = player;
        [player release];
        
        currentScreenIndex = 0;
        
        controllerState = SCHStoryInteractionControllerStateInitialised;
        
        // note that background audio monitoring has been moved into SCHQueuedAudioPlayer
        
    }
    return self;
}

- (void)setControllerState:(SCHStoryInteractionControllerState)newControllerState
{
    if (controllerState == newControllerState) {
        return;
    }

    controllerState = newControllerState;

    switch (controllerState) {
        case SCHStoryInteractionControllerStateInitialised:
        {
            break;
        }   
        case SCHStoryInteractionControllerStateAskingOpeningQuestion:
        case SCHStoryInteractionControllerStateInteractionReadingAnswerWithoutPause:
        {
            self.readAloudButton.enabled = NO;
            break;
        }
        case SCHStoryInteractionControllerStateInteractionReadingAnswerWithPause:
        {
            self.readAloudButton.enabled = NO;
            [self storyInteractionDisableUserInteraction];
            break;
        }   
        case SCHStoryInteractionControllerStateInteractionFinishedSuccessfully:
        {
            self.readAloudButton.enabled = NO;
            
            // report success so that the reading view can keep track of it properly
            if (delegate && [delegate respondsToSelector:@selector(storyInteractionController:willDismissWithSuccess:)]) {
                [delegate storyInteractionController:self willDismissWithSuccess:YES];
            }
            [self storyInteractionDisableUserInteraction];
            break;
        }   
        case SCHStoryInteractionControllerStateInteractionInProgress:
        {
            self.readAloudButton.enabled = [self shouldPlayQuestionAudioForViewAtIndex:self.currentScreenIndex];
            [self storyInteractionEnableUserInteraction];
            break;
        }   
        default:
        {
            NSLog(@"Warning: unknown SI controller state (%d)", controllerState);
            break;
        }
    }
}

- (void)presentInHostView:(UIView *)hostView withInterfaceOrientation:(UIInterfaceOrientation)aInterfaceOrientation
{
    // dim the host view
    if ([self frameStyleForViewAtIndex:self.currentScreenIndex] != SCHStoryInteractionTitleOverlaysContents && self.shadeView == nil) {
        UIView *shade = [[UIView alloc] initWithFrame:hostView.bounds];
        shade.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        shade.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shadeView = shade;
        [hostView addSubview:shade];
        [shade release];
    }

    NSString *questionAudioPath = [self audioPathForQuestion];

    if (self.containerView == nil) {
        [self enqueueAudioWithPath:[storyInteraction storyInteractionOpeningSoundFilename] fromBundle:YES];        

        self.xpsProvider = [[SCHBookManager sharedBookManager] threadSafeCheckOutXPSProviderForBookIdentifier:self.bookIdentifier];
        
        // set up the transparent full-size container to trap touch events before they get
        // to the underlying view; this effectively makes the story interaction modal
        UIView *container = [[UIView alloc] initWithFrame:hostView.bounds];
        container.userInteractionEnabled = YES;
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectZero];
        background.contentMode = UIViewContentModeScaleToFill;
        [container addSubview:background];
        
        if ([self frameStyleForViewAtIndex:self.currentScreenIndex] != SCHStoryInteractionNoTitle) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
            title.backgroundColor = [UIColor clearColor];            
            self.titleView = title;
            [self setupTitle];
            [background addSubview:title];
            [title release];   
        }
        
        NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
        UIImage *closeImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bolt-%@", age]];
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:closeImage forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:self.closeButton];
        
        if (questionAudioPath) {
            UIImage *readAloudImage = [UIImage imageNamed:@"storyinteraction-read-aloud"];
            self.readAloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.readAloudButton.bounds = (CGRect){ CGPointZero, readAloudImage.size };
            [self.readAloudButton setImage:readAloudImage forState:UIControlStateNormal];
            [self.readAloudButton setImage:readAloudImage forState:UIControlStateDisabled];
            [self.readAloudButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:self.readAloudButton];
        }
        
        self.containerView = container;
        self.backgroundView = background;
        [container release];
        [background release];
        
        [hostView addSubview:self.containerView];
    }

    self.interfaceOrientation = aInterfaceOrientation;

    // put multiple views at the top-level in the nib for multi-screen interactions
    UIView *newContentsView = [self.nibObjects objectAtIndex:self.currentScreenIndex];
    CGSize maxContentsSize = [self maximumContentsSize];
    if (CGRectGetWidth(newContentsView.bounds) > maxContentsSize.height || CGRectGetHeight(newContentsView.bounds) > maxContentsSize.width) {
        NSLog(@"contentView %d is too large: %@", self.currentScreenIndex, NSStringFromCGRect(newContentsView.bounds));
    }
    
    dispatch_block_t setupViews = ^{
        [self setupGeometryForContentsView:newContentsView contentsSize:newContentsView.bounds.size];
        self.contentsView.alpha = 0;
        newContentsView.alpha = 1;
        newContentsView.transform = CGAffineTransformIdentity;
        self.backgroundView.image = [self backgroundImage];
    };
    
    if (self.contentsView != nil) {
        // on iPad, animate the transition between screens
        NSAssert([self frameStyleForViewAtIndex:self.currentScreenIndex] != SCHStoryInteractionTitleOverlaysContents, @"can't have multiple views with SCHStoryInteractionTitleOverlaysContents");
        UIView *oldContentsView = self.contentsView;
        newContentsView.alpha = 0;
        newContentsView.transform = CGAffineTransformMakeScale(CGRectGetWidth(oldContentsView.bounds)/CGRectGetWidth(newContentsView.bounds),
                                                               CGRectGetHeight(oldContentsView.bounds)/CGRectGetHeight(newContentsView.bounds));
        newContentsView.center = oldContentsView.center;
        [self.backgroundView addSubview:newContentsView];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [UIView animateWithDuration:0.3
                             animations:setupViews
                             completion:^(BOOL finished) {
                                 [oldContentsView removeFromSuperview];
                             }];
        } else {
            setupViews();
            [oldContentsView removeFromSuperview];
        }
    } else {
        setupViews();
        if ([self frameStyleForViewAtIndex:self.currentScreenIndex] == SCHStoryInteractionTitleOverlaysContents) {
            [self.containerView addSubview:newContentsView];
            [self.backgroundView setUserInteractionEnabled:NO];
        } else {
            [self.backgroundView addSubview:newContentsView];
            [self.backgroundView setUserInteractionEnabled:YES];
        }
    }
    
    [self.containerView bringSubviewToFront:self.backgroundView];
    [self.containerView bringSubviewToFront:self.closeButton];
    [self.containerView bringSubviewToFront:self.readAloudButton];
    
    self.contentsView = newContentsView;
    
    [self setTitle:[self.storyInteraction interactionViewTitle]];
    [self setupViewAtIndex:self.currentScreenIndex];

    if (questionAudioPath && [self shouldPlayQuestionAudioForViewAtIndex:self.currentScreenIndex]) {
        [self enqueueAudioWithPath:questionAudioPath
                        fromBundle:NO
                        startDelay:0
            synchronizedStartBlock:nil
              synchronizedEndBlock:^{
                  self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
              }];
        
        self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
    } else {
        self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
    }
}

- (void)setupTitle
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    BOOL hasShadow = NO;
    
    if ([self.storyInteraction isOlderStoryInteraction]) {
        hasShadow = YES;
        self.titleView.font = [UIFont fontWithName:@"Arial Black" size:(iPad ? 30 : 25)];
    } else {
        self.titleView.font = [UIFont fontWithName:@"Arial-BoldMT" size:(iPad ? 22 : 17)];
    }
    
    self.titleView.textAlignment = UITextAlignmentCenter;
    self.titleView.textColor = [self.storyInteraction isOlderStoryInteraction] ? [UIColor whiteColor] : [UIColor SCHBlue2Color];
    self.titleView.adjustsFontSizeToFitWidth = YES;
    self.titleView.numberOfLines = 2;
    if (hasShadow) {
        self.titleView.layer.shadowOpacity = 0.7f;
        self.titleView.layer.shadowRadius = 2;
        self.titleView.layer.shadowOffset = CGSizeZero;
    }
}

- (void)presentNextView
{
    UIView *host = [self.containerView superview];
    self.currentScreenIndex = (self.currentScreenIndex + 1) % [self.nibObjects count];
    [self presentInHostView:host withInterfaceOrientation:self.interfaceOrientation];

    if ([self frameStyleForViewAtIndex:self.currentScreenIndex] == SCHStoryInteractionNoTitle) {
        [self.titleView setHidden:YES];
    } else {
        [self.titleView setHidden:NO];
    }
}

- (void)resizeCurrentViewToSize:(CGSize)newSize withAdditionalAdjustments:(dispatch_block_t)adjustmentBlock animated:(BOOL)animated
{
    dispatch_block_t setupViews = ^{
        [self setupGeometryForContentsView:self.contentsView contentsSize:newSize];
       
        if (adjustmentBlock) {
            adjustmentBlock();
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:setupViews
                         completion:nil];
    } else {
        setupViews();
    }
}

- (void)setupGeometryForContentsView:(UIView *)contents contentsSize:(CGSize)contentsSize
{
    UIView *container = self.containerView;
    UIImageView *background = self.backgroundView;
    UIView *title = self.titleView;
    UIButton *close = self.closeButton;
    UIButton *readAloud = self.readAloudButton;
    SCHFrameStyle currentFrameStyle = [self frameStyleForViewAtIndex:self.currentScreenIndex];
    
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    UIEdgeInsets contentInsets;
    UIEdgeInsets titleInsets;
    CGPoint closePosition;     // relative to top-left corner
    CGPoint readAloudPosition; // relative to top-right corner
    if (iPad) {
        contentInsets = UIEdgeInsetsMake((currentFrameStyle == SCHStoryInteractionNoTitle ? 40 : 130), 40, 40, 40);
        titleInsets = UIEdgeInsetsMake(45, 65, 21, 65);
        closePosition = [self.storyInteraction isOlderStoryInteraction] ? CGPointMake(3, -8) : CGPointMake(9, -17);
        readAloudPosition = CGPointMake(-5, 5);
    } else {
        contentInsets = UIEdgeInsetsMake((currentFrameStyle == SCHStoryInteractionNoTitle ? 5 : 70), 5, 5, 5);
        titleInsets = UIEdgeInsetsMake(5, 55, 5, 55);
        closePosition = CGPointMake(10, 7);
        readAloudPosition = CGPointMake(-13, 15);
    }
    
    const BOOL shouldRotate = ([self shouldPresentInPortraitOrientation]
                               ? UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
                               : UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
    
    CGRect superviewBounds = container.superview.bounds;
    if (shouldRotate) {
        container.transform = CGAffineTransformMakeRotation(-M_PI/2);
        container.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetHeight(superviewBounds), CGRectGetWidth(superviewBounds)));
    } else {
        container.transform = CGAffineTransformIdentity;
        container.bounds = CGRectIntegral(superviewBounds);
    }
    container.center = CGPointMake(floor(CGRectGetMidX(superviewBounds)), floor(CGRectGetMidY(superviewBounds)));
    
    CGFloat backgroundWidth, backgroundHeight;
    switch ([self frameStyleForViewAtIndex:self.currentScreenIndex]) {
        case SCHStoryInteractionFullScreen: {
            CGSize size = [UIScreen mainScreen].bounds.size;  
            backgroundWidth = size.height;
            backgroundHeight = size.width;
            // FIXME: should not be setting frame when transforms are used
            background.frame = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            contents.frame = background.frame; 
            break;
        }
        case SCHStoryInteractionTitle: 
        case SCHStoryInteractionTransparentTitle:                            
        case SCHStoryInteractionNoTitle: {
            backgroundWidth = MAX(background.image.size.width, contentsSize.width + contentInsets.left + contentInsets.right);
            backgroundHeight = MAX(background.image.size.height, contentsSize.height + contentInsets.top + contentInsets.bottom);
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            background.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            title.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, backgroundWidth, contentInsets.top), titleInsets);
            contents.bounds = CGRectMake(0, 0, contentsSize.width, contentsSize.height);
            contents.center = CGPointMake(floorf(backgroundWidth/2), floorf((backgroundHeight-contentInsets.top-contentInsets.bottom)/2+contentInsets.top));
            break;
        }
        case SCHStoryInteractionTitleOverlaysContents: {
            CGRect titleFrame = [self overlaidTitleFrame];
            if (iPad) {
                backgroundWidth = MAX(background.image.size.width, titleFrame.size.width);
                backgroundHeight = MAX(background.image.size.height, titleFrame.size.height);
                background.center = CGPointMake(floorf(CGRectGetMidX(titleFrame)), floorf(CGRectGetMidY(titleFrame)));
            } else {
                backgroundWidth = background.image.size.width;
                backgroundHeight = background.image.size.height;
                background.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            }
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            contents.bounds = container.bounds;
            contents.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            titleInsets.top = titleInsets.bottom;
            title.frame = UIEdgeInsetsInsetRect((CGRect){CGPointZero, titleFrame.size}, titleInsets);
            break;
        }
    }
    
    closePosition.x += background.frame.origin.x;
    closePosition.y += background.frame.origin.y;
    readAloudPosition.x += background.frame.origin.x;
    readAloudPosition.y += background.frame.origin.y;
    
    UIImage *closeImage = [close imageForState:UIControlStateNormal];
    close.bounds = (CGRect){ CGPointZero, closeImage.size };
    close.center = CGPointMake(floorf(closePosition.x+closeImage.size.width/2), floorf(closePosition.y+closeImage.size.height/2));
    
    readAloud.center = CGPointMake(floorf(backgroundWidth+readAloudPosition.x-CGRectGetMidX(readAloud.bounds)),
                                   floorf(readAloudPosition.y+CGRectGetMidX(readAloud.bounds)));
}

- (CGSize)maximumContentsSize
{
    SCHFrameStyle currentFrameStyle = [self frameStyleForViewAtIndex:self.currentScreenIndex];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || currentFrameStyle == SCHStoryInteractionFullScreen) {
        return [UIScreen mainScreen].bounds.size; 
    }
    switch (currentFrameStyle) {
        case SCHStoryInteractionNoTitle:
            return CGSizeMake(315.0, 470.0);
        case SCHStoryInteractionTitle:
        case SCHStoryInteractionTransparentTitle:                
        default:
            return CGSizeMake(250.0, 470.0);
    }
}

- (UIImage *)backgroundImage
{
    NSString *suffix;
    switch ([self frameStyleForViewAtIndex:self.currentScreenIndex]) {
        case SCHStoryInteractionFullScreen:
            return nil;
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
    
    NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
    UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bg-%@%@", age, suffix]];
    UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2-1
                                                                      topCapHeight:backgroundImage.size.height/2-1];
    return backgroundStretch;
}

#pragma mark - orientation

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
                         if ([self frameStyleForViewAtIndex:self.currentScreenIndex] != SCHStoryInteractionTitleOverlaysContents) {
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
    
    [self setupGeometryForContentsView:self.contentsView contentsSize:self.contentsView.bounds.size];
}

- (BOOL)isLandscape
{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (CGAffineTransform)affineTransformForCurrentOrientation
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        return CGAffineTransformIdentity;
    } else {
        return CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI/2), -CGRectGetWidth(self.containerView.bounds), 0);
    }
}

#pragma mark - actions

- (void)closeButtonTapped:(id)sender
{
    [self removeFromHostView];
}

- (void)setUserInteractionsEnabled:(BOOL)enabled
{
    self.containerView.superview.userInteractionEnabled = enabled;
    self.containerView.userInteractionEnabled = enabled;
}

- (BOOL)isUserInteractionsEnabled
{
    return self.containerView.userInteractionEnabled;
}

#pragma mark - Notification methods

- (void)removeFromHostView
{
    [self cancelQueuedAudio];
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.bookIdentifier];
    
    void (^teardownBlock)(void) = ^{ 
        // always, always re-enable user interactions for the superview...
        [self setUserInteractionsEnabled:YES];
        
        [self.containerView removeFromSuperview];
        [self.shadeView removeFromSuperview];
        
        if (delegate && [delegate respondsToSelector:@selector(storyInteractionControllerDidDismiss:)]) {
            // may result in self being dealloc'ed so don't do anything else after this
            [delegate storyInteractionControllerDidDismiss:self];
        }
    };
    
    if (self.controllerState == SCHStoryInteractionControllerStateInteractionFinishedSuccessfully) {
        double delayInSeconds = 0.75;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            teardownBlock();
        });
    } else {
        teardownBlock();
    }
}

- (void)didSuccessfullyCompleteInteraction
{
    NSLog(@"**** FIXME: a story interaction is using an obsolete method. ****");
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionController:willDismissWithSuccess:)]) {
        [delegate storyInteractionController:self willDismissWithSuccess:YES];
    }
}
#pragma mark - Audio methods

- (IBAction)playAudioButtonTapped:(id)sender
{
    if (![self.audioPlayer isPlaying]) { 
        NSString *path = [self audioPathForQuestion];
        if (path != nil) {
            [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
            [self enqueueAudioWithPath:path 
                            fromBundle:NO 
                            startDelay:0 
                synchronizedStartBlock:^{
                    self.controllerState = SCHStoryInteractionControllerStateAskingOpeningQuestion;
                    
                }
                  synchronizedEndBlock:^{
                      self.controllerState = SCHStoryInteractionControllerStateInteractionInProgress;
                  }
             ];

        }   
    }
}

- (void)playDefaultButtonAudio
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionCorrectAnswerSoundFilename] fromBundle:YES];
}

- (void)playRevealAudio
{
    [self cancelQueuedAudioExecutingSynchronizedBlocksImmediately];
    [self enqueueAudioWithPath:[self.storyInteraction storyInteractionRevealSoundFilename] fromBundle:YES];
}

- (void)playAudioAtPath:(NSString *)path completion:(void (^)(void))completion
{
    [self.audioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
    [self enqueueAudioWithPath:path fromBundle:NO startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:completion];
}

- (void)playBundleAudioWithFilename:(NSString *)filename completion:(void (^)(void))completion
{
    [self.audioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
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
    [self.audioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
}

- (void)cancelQueuedAudioExecutingSynchronizedBlocksImmediately
{
    [self.audioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:YES];
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

#pragma mark - SCHStoryInteractionControllerStateReactions - MUST BE OVERRIDDEN IN SUBCLASS

- (void)storyInteractionEnableUserInteraction
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)storyInteractionDisableUserInteraction
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

#pragma mark - optional subclass overrides

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

- (SCHFrameStyle)frameStyleForViewAtIndex:(NSInteger)viewIndex
{
    return self.frameStyle;
}

- (CGRect)overlaidTitleFrame
{
    return CGRectZero;
}

- (BOOL)shouldPresentInPortraitOrientation
{
    return NO;
}

@end

