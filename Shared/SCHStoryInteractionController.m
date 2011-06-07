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

#define kBackgroundLeftCap 10
#define kBackgroundTopCap_iPhone 40
#define kBackgroundTopCap_iPad 50
#define kContentsInsetLeft 5
#define kContentsInsetRight 5
#define kContentsInsetTop_iPhone 36
#define kContentsInsetTop_iPad 46
#define kContentsInsetBottom 5
#define kTitleInsetLeft 10
#define kTitleInsetTop 10

@interface SCHStoryInteractionController ()

@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, retain) UIView *contentsView;
@property (nonatomic, retain) UIImageView *backgroundView;

- (UIImage *)deviceSpecificImageNamed:(NSString *)name;
- (void)updateOrientation;

@end

@implementation SCHStoryInteractionController

@synthesize containerView;
@synthesize nibObjects;
@synthesize contentsView;
@synthesize backgroundView;
@synthesize storyInteraction;
@synthesize delegate;
@synthesize interfaceOrientation;

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
    [self removeFromHostView];
    [containerView release];
    [nibObjects release];
    [contentsView release];
    [backgroundView release];
    [storyInteraction release];
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
    }
    return self;
}

- (void)presentInHostView:(UIView *)hostView
{
    if (self.containerView == nil) {
        
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
        titleView.font = [UIFont boldSystemFontOfSize:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 24 : 20];
        titleView.text = [self.storyInteraction title];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.textColor = [UIColor whiteColor];
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

- (IBAction)playAudioButtonTapped:(id)sender
{
    NSLog(@"Playing audio"); 
}

- (void)removeFromHostView
{
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

#pragma mark - subclass overrides

- (void)setupView
{}

@end
