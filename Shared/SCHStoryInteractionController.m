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
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIButton *readAloudButton;
@property (nonatomic, retain) UIImageView *backgroundView;
@property (nonatomic, retain) SCHQueuedAudioPlayer *audioPlayer;

- (void)setupGeometryForContainerView:(UIView *)containerView
                       backgroundView:(UIImageView *)backgroundView
                         contentsView:(UIView *)contentsView
                            titleView:(UIView *)titleView
                          closeButton:(UIButton *)closeButton
                      readAloudButton:(UIButton *)readAloudButton;

- (CGSize)maximumContentsSize;
- (UIImage *)backgroundImage;

@end

@implementation SCHStoryInteractionController

@synthesize xpsProvider;
@synthesize isbn;
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
    [closeButton release];
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
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:closeImage forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [background addSubview:self.closeButton];

        if (questionAudioPath) {
            UIImage *readAloudImage = [UIImage imageNamed:@"storyinteraction-read-aloud"];
            self.readAloudButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.readAloudButton.bounds = (CGRect){ CGPointZero, readAloudImage.size };
            [self.readAloudButton setImage:readAloudImage forState:UIControlStateNormal];
            [self.readAloudButton addTarget:self action:@selector(playAudioButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:self.readAloudButton];
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
        [self setupGeometryForContainerView:self.containerView
                             backgroundView:self.backgroundView
                               contentsView:newContentsView
                                  titleView:self.titleView
                                closeButton:self.closeButton
                            readAloudButton:self.readAloudButton];
        self.contentsView.alpha = 0;
        newContentsView.alpha = 1;
        newContentsView.transform = CGAffineTransformIdentity;
    };
    
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
                         animations:setupViews
                         completion:^(BOOL finished) {
                             [oldContentsView removeFromSuperview];
                         }];
    } else {
        setupViews();
        if (self.frameStyle == SCHStoryInteractionTitleOverlaysContents) {
            [self.containerView addSubview:newContentsView];
        } else {
            [self.backgroundView addSubview:newContentsView];
        }
    }
    
    [self.containerView bringSubviewToFront:self.backgroundView];
    [self.backgroundView bringSubviewToFront:self.closeButton];
    [self.backgroundView bringSubviewToFront:self.readAloudButton];
    
    self.contentsView = newContentsView;
    
    [self setTitle:[self.storyInteraction interactionViewTitle]];
    [self setupViewAtIndex:self.currentScreenIndex];
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
    [self setupGeometryForContainerView:self.containerView
                         backgroundView:self.backgroundView
                           contentsView:self.contentsView
                              titleView:self.titleView
                            closeButton:self.closeButton
                        readAloudButton:self.readAloudButton];
}

- (void)setupGeometryForContainerView:(UIView *)container
                       backgroundView:(UIImageView *)background
                         contentsView:(UIView *)contents
                            titleView:(UIView *)title
                          closeButton:(UIButton *)close
                      readAloudButton:(UIButton *)readAloud
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
    
    CGRect superviewBounds = container.superview.bounds;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        container.transform = CGAffineTransformMakeRotation(-M_PI/2);
        container.bounds = CGRectIntegral(CGRectMake(0, 0, CGRectGetHeight(superviewBounds), CGRectGetWidth(superviewBounds)));
    } else {
        container.transform = CGAffineTransformIdentity;
        container.bounds = CGRectIntegral(superviewBounds);
    }
    container.center = CGPointMake(floor(CGRectGetMidX(superviewBounds)), floor(CGRectGetMidY(superviewBounds)));

    CGFloat backgroundWidth, backgroundHeight;
    switch (self.frameStyle) {
        case SCHStoryInteractionFullScreen: {
            CGSize size = [UIScreen mainScreen].bounds.size;  
            backgroundWidth = size.height;
            backgroundHeight = size.width;
            background.frame = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            contents.frame = background.frame; 
            break;
        }
        case SCHStoryInteractionTitle: 
        case SCHStoryInteractionTransparentTitle:                            
        case SCHStoryInteractionNoTitle: {
            backgroundWidth = MAX(background.image.size.width, CGRectGetWidth(contents.bounds) + contentInsets.left + contentInsets.right);
            backgroundHeight = MAX(background.image.size.height, CGRectGetHeight(contents.bounds) + contentInsets.top + contentInsets.bottom);
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            background.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            contents.center = CGPointMake(floorf(backgroundWidth/2), floorf((backgroundHeight-contentInsets.top-contentInsets.bottom)/2+contentInsets.top));
            title.frame = UIEdgeInsetsInsetRect(CGRectMake(0, 0, backgroundWidth, contentInsets.top), titleInsets);
            break;
        }
        case SCHStoryInteractionTitleOverlaysContents: {
            CGRect titleFrame = [self overlaidTitleFrame];
            backgroundWidth = MAX(background.image.size.width, titleFrame.size.width);
            backgroundHeight = MAX(background.image.size.height, titleFrame.size.height);
            background.bounds = CGRectIntegral(CGRectMake(0, 0, backgroundWidth, backgroundHeight));
            background.center = CGPointMake(floorf(CGRectGetMidX(titleFrame)), floorf(CGRectGetMidY(titleFrame)));
            contents.bounds = container.bounds;
            contents.center = CGPointMake(floorf(CGRectGetMidX(container.bounds)), floorf(CGRectGetMidY(container.bounds)));
            titleInsets.top = titleInsets.bottom;
            title.frame = UIEdgeInsetsInsetRect(background.bounds, titleInsets);
            break;
        }
    }
    
    UIImage *closeImage = [close imageForState:UIControlStateNormal];
    close.bounds = (CGRect){ CGPointZero, closeImage.size };
    close.center = CGPointMake(floorf(closePosition.x+closeImage.size.width/2), floorf(closePosition.y+closeImage.size.height/2));

    readAloud.center = CGPointMake(floorf(backgroundWidth+readAloudPosition.x-CGRectGetMidX(readAloud.bounds)),
                                   floorf(readAloudPosition.y+CGRectGetMidX(readAloud.bounds)));
}

- (CGSize)maximumContentsSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || self.frameStyle == SCHStoryInteractionFullScreen) {
        return [UIScreen mainScreen].bounds.size; 
    }
    switch (self.frameStyle) {
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
    switch (self.frameStyle) {
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

