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
#import "SCHStoryInteractionStandaloneViewController.h"
#import "SCHStoryInteractionTypes.h"
#import "SCHStoryInteractionControllerMultipleChoiceText.h"
#import "SCHStoryInteractionControllerDelegate.h"
#import "SCHStoryInteractionDraggableView.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHQueuedAudioPlayer.h"

@interface SCHStoryInteractionController ()

@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, assign) NSInteger currentScreenIndex;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIButton *readAloudButton;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) SCHQueuedAudioPlayer *audioPlayer;
@property (nonatomic, retain) UIView *shadeView;

- (BOOL)currentFrameStyleOverlaysContents;
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
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *nibName = nil;
        Class controllerClass = [self class];
        do {
            NSString *controllerClassName = [NSString stringWithCString:class_getName(controllerClass) encoding:NSUTF8StringEncoding];
            NSString *prefix = [controllerClassName stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
            NSString *suffix = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @"_iPhone");
            prefix = [prefix stringByReplacingOccurrencesOfString:suffix withString:@""];
            controllerClass = class_getSuperclass(controllerClass);
            nibName = [NSString stringWithFormat:@"%@%@", prefix, suffix];
        } while (controllerClass != nil && [mainBundle pathForResource:nibName ofType:@"nib"] == nil);
        
        if (!nibName) {
            NSLog(@"can't find NIB for Story Interaction controller '%s'", object_getClassName(self));
            return nil;
        }
        
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
            [self storyInteractionDisableUserInteraction];
            break;
        }   
        case SCHStoryInteractionControllerStateInteractionInProgress:
        {
            self.readAloudButton.enabled = YES;
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
    if (![self currentFrameStyleOverlaysContents] && self.shadeView == nil) {
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
        container.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
                                      | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                      | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        
        UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectZero];
        background.contentMode = UIViewContentModeScaleToFill;
        background.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
                                       | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        [container addSubview:background];
        
        if ([self frameStyleForViewAtIndex:self.currentScreenIndex] != SCHStoryInteractionNoTitle) {
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
            title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            title.backgroundColor = [UIColor clearColor];            
            self.titleView = title;
            [self setupTitle];
            [background addSubview:title];
            [title release];   
        }

#ifdef debug_layout
        container.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
        background.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.5];
#endif
        
        self.containerView = container;
        self.backgroundView = background;
        [container release];
        [background release];
        
        [hostView addSubview:self.containerView];
    }

    if (questionAudioPath) {
        if (!self.readAloudButton) {
            UIImage *readAloudImage = [UIImage imageNamed:@"storyinteraction-read-aloud"];
            self.readAloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.readAloudButton.autoresizingMask = 0;
            self.readAloudButton.bounds = (CGRect){ CGPointZero, readAloudImage.size };
            [self.readAloudButton setImage:readAloudImage forState:UIControlStateNormal];
            [self.readAloudButton setImage:readAloudImage forState:UIControlStateDisabled];
            [self.readAloudButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        [self.readAloudButton removeFromSuperview];
        self.readAloudButton = nil;
    }
    
    if ([self shouldShowCloseButtonForViewAtIndex:self.currentScreenIndex]) {
        if (!self.closeButton) {
            NSString *age = [self.storyInteraction isOlderStoryInteraction] ? @"older" : @"younger";
            UIImage *closeImage = [UIImage imageNamed:[NSString stringWithFormat:@"storyinteraction-bolt-%@", age]];
            self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.closeButton.autoresizingMask = 0;
            self.closeButton.bounds = (CGRect){ CGPointZero, closeImage.size };
            [self.closeButton setImage:closeImage forState:UIControlStateNormal];
            [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        [self.closeButton removeFromSuperview];
        self.closeButton = nil;
    }
    
    self.interfaceOrientation = aInterfaceOrientation;

    // put multiple views at the top-level in the nib for multi-screen interactions
    UIView *newContentsView = [self.nibObjects objectAtIndex:self.currentScreenIndex];
    
    dispatch_block_t setupViews = ^{
        self.backgroundView.image = [self backgroundImage];
        [self setupGeometryForContentsView:newContentsView contentsSize:newContentsView.bounds.size];
        self.contentsView.alpha = 0;
        newContentsView.alpha = 1;
        newContentsView.transform = CGAffineTransformIdentity;
    };
    
    if (self.contentsView != nil) {
        // if required, animate the transition between screens
        NSAssert(![self currentFrameStyleOverlaysContents], @"can't have multiple views with SCHStoryInteractionTitleOverlaysContentsAtTop/Bottom");
        UIView *oldContentsView = self.contentsView;
        newContentsView.alpha = 0;
        newContentsView.transform = CGAffineTransformMakeScale(CGRectGetWidth(oldContentsView.bounds)/CGRectGetWidth(newContentsView.bounds),
                                                               CGRectGetHeight(oldContentsView.bounds)/CGRectGetHeight(newContentsView.bounds));
        newContentsView.center = oldContentsView.center;
        [self.backgroundView addSubview:newContentsView];
        
        if ([self shouldAnimateTransitionBetweenViews]) {
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
        if ([self currentFrameStyleOverlaysContents]) {
            [self.containerView addSubview:newContentsView];
            [self.containerView addSubview:self.readAloudButton];
            [self.containerView addSubview:self.closeButton];
            [self.backgroundView setUserInteractionEnabled:NO];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.backgroundView.autoresizingMask &= ~UIViewAutoresizingFlexibleLeftMargin;
            }
        } else {
            [self.backgroundView addSubview:newContentsView];
            [self.backgroundView addSubview:self.readAloudButton];
            [self.backgroundView addSubview:self.closeButton];
            [self.backgroundView setUserInteractionEnabled:YES];
        }
        setupViews();
    }
    
    [self.containerView bringSubviewToFront:self.backgroundView];
    [self.closeButton.superview bringSubviewToFront:self.closeButton];
    [self.readAloudButton.superview bringSubviewToFront:self.readAloudButton];
    
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
    
    // force a relayout for the current orientation
    [self willRotateToInterfaceOrientation:aInterfaceOrientation duration:0];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
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

- (void)resizeCurrentViewToSize:(CGSize)newSize animationDuration:(NSTimeInterval)animationDuration withAdditionalAdjustments:(dispatch_block_t)adjustmentBlock
{
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setupGeometryForContentsView:self.contentsView contentsSize:newSize];
                         if (adjustmentBlock) {
                             adjustmentBlock();
                         }
                     }
                     completion:nil];
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

    CGRect superviewBounds = container.superview.bounds;
    container.bounds = CGRectIntegral(superviewBounds);
    container.center = CGPointMake(floor(CGRectGetMidX(superviewBounds)), floor(CGRectGetMidY(superviewBounds)));
    
    CGFloat backgroundWidth, backgroundHeight;
    switch (currentFrameStyle) {
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
            close.center = CGPointMake(closePosition.x+CGRectGetWidth(close.bounds)/2, closePosition.y+CGRectGetHeight(close.bounds)/2);
            readAloud.center = CGPointMake(backgroundWidth+readAloudPosition.x-CGRectGetWidth(readAloud.bounds)/2,
                                           readAloudPosition.y+CGRectGetHeight(readAloud.bounds)/2);
            break;
        }
        case SCHStoryInteractionTitleOverlaysContentsAtTop: {
            CGRect titleFrame = [self overlaidTitleFrame];
            backgroundWidth = MAX(background.image.size.width, titleFrame.size.width);
            backgroundHeight = MAX(background.image.size.height, titleFrame.size.height);
            if (iPad) {
                background.center = CGPointMake(floorf(CGRectGetMidX(titleFrame)), floorf(CGRectGetMidY(titleFrame)));
            } else {
                background.center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds));
            }
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            contents.bounds = container.bounds;
            contents.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            titleInsets.top = titleInsets.bottom;
            title.frame = UIEdgeInsetsInsetRect((CGRect){CGPointZero, titleFrame.size}, titleInsets);
            close.center = CGPointMake(background.center.x-backgroundWidth/2+closePosition.x+CGRectGetWidth(close.bounds)/2,
                                       background.center.y-backgroundHeight/2+closePosition.y+CGRectGetHeight(close.bounds)/2);
            readAloud.center = CGPointMake(background.center.x+backgroundWidth/2+readAloudPosition.x-CGRectGetWidth(readAloud.bounds)/2,
                                           background.center.y-backgroundHeight/2+readAloudPosition.y+CGRectGetHeight(readAloud.bounds)/2);
            break;
        }
        case SCHStoryInteractionTitleOverlaysContentsAtBottom: {
            CGRect titleFrame = [self overlaidTitleFrame];
            backgroundWidth = MAX(background.image.size.width, titleFrame.size.width);
            backgroundHeight = MAX(background.image.size.height, titleFrame.size.height);
            if (iPad) {
                background.center = CGPointMake(floorf(CGRectGetMidX(titleFrame)), floorf(CGRectGetHeight(container.bounds)-CGRectGetMidY(titleFrame)));
            } else {
                background.center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds));
            }
            background.transform = CGAffineTransformMakeRotation(M_PI);
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            contents.bounds = container.bounds;
            contents.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            titleInsets.top = titleInsets.bottom;
            title.frame = UIEdgeInsetsInsetRect((CGRect){CGPointZero, titleFrame.size}, titleInsets);
            title.transform = CGAffineTransformMakeRotation(M_PI);
            close.center = CGPointMake(background.center.x-backgroundWidth/2+closePosition.x+CGRectGetWidth(close.bounds)/2,
                                       background.center.y+backgroundHeight/2-closePosition.y-CGRectGetHeight(close.bounds)/2);
            readAloud.center = CGPointMake(background.center.x+backgroundWidth/2+readAloudPosition.x-CGRectGetWidth(readAloud.bounds)/2,
                                           background.center.y+backgroundHeight/2-readAloudPosition.y-CGRectGetHeight(readAloud.bounds)/2);
            break;
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.interfaceOrientation = toInterfaceOrientation;
    
    CGSize size = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? [self maximumContentsSize] : [self iPadContentsSizeForOrientation:toInterfaceOrientation]);
    [self resizeCurrentViewToSize:size
                animationDuration:duration
        withAdditionalAdjustments:^{
            [self rotateToOrientation:toInterfaceOrientation];
        }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (CGSize)maximumContentsSize
{
    SCHFrameStyle currentFrameStyle = [self frameStyleForViewAtIndex:self.currentScreenIndex];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || currentFrameStyle == SCHStoryInteractionFullScreen) {
        return [UIScreen mainScreen].bounds.size; 
    }
    switch (currentFrameStyle) {
        case SCHStoryInteractionNoTitle:
            return (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? CGSizeMake(315.0, 470.0) : CGSizeMake(470.0, 315.0));
        case SCHStoryInteractionTitle:
        case SCHStoryInteractionTransparentTitle:                
        default:
            return (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? CGSizeMake(310.0, 410.0) : CGSizeMake(470.0, 250.0));
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
        case SCHStoryInteractionTitleOverlaysContentsAtTop:
        case SCHStoryInteractionTitleOverlaysContentsAtBottom:
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

- (BOOL)currentFrameStyleOverlaysContents
{
    SCHFrameStyle style = [self frameStyleForViewAtIndex:self.currentScreenIndex];
    return (style == SCHStoryInteractionTitleOverlaysContentsAtTop || style == SCHStoryInteractionTitleOverlaysContentsAtBottom);
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
    // report success so that the reading view can keep track of it properly
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionController:willDismissWithSuccess:)]) {
        BOOL success = (self.controllerState == SCHStoryInteractionControllerStateInteractionFinishedSuccessfully);
        [delegate storyInteractionController:self willDismissWithSuccess:success];
    }

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

- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock
{
    [self enqueueAudioWithPath:path fromBundle:fromBundle startDelay:startDelay synchronizedStartBlock:startBlock synchronizedEndBlock:endBlock requiresEmptyQueue:NO];
}

- (void)enqueueAudioWithPath:(NSString *)path
                  fromBundle:(BOOL)fromBundle
                  startDelay:(NSTimeInterval)startDelay
      synchronizedStartBlock:(dispatch_block_t)startBlock
        synchronizedEndBlock:(dispatch_block_t)endBlock
          requiresEmptyQueue:(BOOL)requiresEmpty;
{
    if (!requiresEmpty) {
        [self.audioPlayer enqueueGap:startDelay];
    }
    
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
    
    [self.audioPlayer enqueueAudioTaskWithFetchBlock:fetchBlock synchronizedStartBlock:startBlock synchronizedEndBlock:endBlock requiresEmptyQueue:requiresEmpty];
}

- (void)enqueueAudioWithPath:(NSString *)path fromBundle:(BOOL)fromBundle
{
    [self enqueueAudioWithPath:path fromBundle:fromBundle startDelay:0 synchronizedStartBlock:nil synchronizedEndBlock:nil requiresEmptyQueue:NO];
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

- (NSString *)audioPathForYouFoundThemAll
{
    NSArray *filenames = [NSArray arrayWithObjects:@"gen_gotthemall.mp3", @"gen_gotthemal.mp3", nil];
    for (NSString *filename in filenames) {
        NSString *path = [KNFBXPSStoryInteractionsDirectory stringByAppendingPathComponent:filename];
        if ([self.xpsProvider componentExistsAtPath:path]) {
            return path;
        }
    }
    return nil;
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

- (BOOL)shouldShowSnapshotOfReadingViewInBackground
{
    // iPhone SIs are full screen so only required on iPad
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (BOOL)supportsAutoRotation
{
    return YES;
}

- (BOOL)shouldPresentInPortraitOrientation
{
    // only meaningful if supportsAutoRotation is NO
    return NO;
}

- (BOOL)shouldShowCloseButtonForViewAtIndex:(NSInteger)screenIndex
{
    return YES;
}

- (BOOL)shouldAnimateTransitionBetweenViews
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
}

- (CGSize)iPadContentsSizeForOrientation:(UIInterfaceOrientation)orientation
{
    return self.contentsView.bounds.size;
}

@end

