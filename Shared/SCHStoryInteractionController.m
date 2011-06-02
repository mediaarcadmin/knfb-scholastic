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

@interface SCHStoryInteractionController ()
@property (nonatomic, retain) NSArray *nibObjects;
@end

@implementation SCHStoryInteractionController

@synthesize nibObjects;
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
    [nibObjects release];
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
    for (id object in self.nibObjects) {
        if ([object isKindOfClass:[UIView class]]) {
            CGPoint center = CGPointMake(CGRectGetMidX(hostView.bounds), CGRectGetMidY(hostView.bounds));
            [(UIView *)object setCenter:center];
            [hostView addSubview:object];
        }
    }
    [self setupView];
}

- (void)removeFromHostView
{
    for (id object in self.nibObjects) {
        if ([object isKindOfClass:[UIView class]]) {
            [object removeFromSuperview];
        }
    }
    
    if (delegate && [delegate respondsToSelector:@selector(storyInteractionControllerDidDismiss:)]) {
        // may result in self being dealloc'ed so don't do anything else after this
        [delegate storyInteractionControllerDidDismiss:self];
    }
}

#pragma mark - subclass overrides

- (void)setupView
{}

@end
