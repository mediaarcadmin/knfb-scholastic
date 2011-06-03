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
#define kBackgroundTopCap 74
#define kContentsInsetLeft 5
#define kContentsInsetRight 5
#define kContentsInsetTop 74
#define kContentsInsetBottom 5
#define kTitleInsetLeft 10
#define kTitleInsetTop 10

@interface SCHStoryInteractionController ()

@property (nonatomic, retain) NSArray *nibObjects;
@property (nonatomic, retain) UIView *contentsView;

@end

@implementation SCHStoryInteractionController

@synthesize containerView;
@synthesize nibObjects;
@synthesize contentsView;
@synthesize storyInteraction;
@synthesize delegate;

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
    // set up the transparent full-size container to trap touch events before they get
    // to the underlying view; this effectively makes the story interaction modal
    UIView *container = [[UIView alloc] initWithFrame:hostView.bounds];
    container.backgroundColor = [UIColor clearColor];
    container.userInteractionEnabled = YES;
    [hostView addSubview:container];
    
    UIImage *backgroundImage = [UIImage imageNamed:[self.storyInteraction isOlderStoryInteraction] ? @"storyinteraction-bg-older" : @"storyinteraction-bg-younger"];
    UIImage *backgroundStretch = [backgroundImage stretchableImageWithLeftCapWidth:kBackgroundLeftCap topCapHeight:kBackgroundTopCap];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundStretch];
    
    // first object in the NIB must be the container view for the interaction
    self.contentsView = [self.nibObjects objectAtIndex:0];
    CGFloat backgroundWidth = CGRectGetWidth(self.contentsView.bounds) + kContentsInsetLeft + kContentsInsetRight;
    CGFloat backgroundHeight = CGRectGetHeight(self.contentsView.bounds) + kContentsInsetTop + kContentsInsetBottom;

    backgroundView.userInteractionEnabled = YES;
    backgroundView.bounds = CGRectMake(0, 0, backgroundWidth, backgroundHeight);
    backgroundView.center = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds));
    self.contentsView.center = CGPointMake(kContentsInsetLeft + CGRectGetWidth(contentsView.bounds)/2,
                                           kContentsInsetTop + CGRectGetHeight(contentsView.bounds)/2);
    [backgroundView addSubview:self.contentsView];
    [container addSubview:backgroundView];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(kTitleInsetLeft, kTitleInsetTop,
                                                                   backgroundWidth - kTitleInsetLeft*2,
                                                                   kContentsInsetTop - kTitleInsetTop*2)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:24];
    titleView.text = [self.storyInteraction title];
    titleView.textAlignment = UITextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    [backgroundView addSubview:titleView];
    [titleView release];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(CGRectGetMinX(backgroundView.frame)-10, CGRectGetMinY(backgroundView.frame)-10, 30, 30);
    [closeButton setImage:[UIImage imageNamed:@"storyinteraction-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:closeButton];

    self.containerView = container;
    [container release];
    [backgroundView release];

    [self setupView];
}

- (void)closeButtonTapped:(id)sender
{
    [self removeFromHostView];
}

- (void)removeFromHostView
{
    [self.containerView removeFromSuperview];
    
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionControllerDidDismiss:)]) {
        // may result in self being dealloc'ed so don't do anything else after this
        [delegate storyInteractionControllerDidDismiss:self];
    }
}

#pragma mark - subclass overrides

- (void)setupView
{}

@end
