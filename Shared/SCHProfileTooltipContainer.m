//
//  SCHProfileTooltipContainer.m
//  Scholastic
//
//  Created by Gordon Christie on 09/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHProfileTooltipContainer.h"

@interface SCHProfileTooltipContainer ()

@property (nonatomic, retain) UIButton *clearBackgroundButton;
@property (nonatomic, retain) SCHProfileTooltip *topTooltip;
@property (nonatomic, retain) SCHProfileTooltip *bottomTooltip;
@property (nonatomic, retain) NSMutableArray *highlightViews;

@end

@implementation SCHProfileTooltipContainer

@synthesize delegate;
@synthesize clearBackgroundButton;
@synthesize topTooltip;
@synthesize bottomTooltip;
@synthesize highlightViews;

- (void)dealloc
{
    delegate = nil;
    [clearBackgroundButton release], clearBackgroundButton = nil;
    [topTooltip release], topTooltip = nil;
    [bottomTooltip release], bottomTooltip = nil;
    [highlightViews release], highlightViews = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.highlightViews = [NSMutableArray array];

        self.clearBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.clearBackgroundButton.frame = frame;
        self.clearBackgroundButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.clearBackgroundButton.backgroundColor = [UIColor clearColor];
        [self.clearBackgroundButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearBackgroundButton];
        

        self.topTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(0, 14, 320, 100)] autorelease];
        [self.topTooltip setTitle:@"Welcome to your Bookshelves!"
                         bodyText:@"Manage individual bookshelves for your children. You’ll need to assign each eBook to a bookshelf before they can be read."];
        self.topTooltip.usesCloseButton = YES;
        self.topTooltip.delegate = self;
        self.topTooltip.backgroundImage = [UIImage imageNamed:@"TooltipTopBackground"];
        self.topTooltip.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.topTooltip];
        

        self.bottomTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(0, 290, 320, 160)] autorelease];
        [self.bottomTooltip setFirstTitle:@"Reading Manager"
                            firstBodyText:@"Go here to assign new eBooks and monitor reading progress."
                              secondTitle:@"Child's Bookshelf"
                           secondBodyText:@"Your child can start reading by selecting their name. Their eBooks will be waiting for them!"];
        self.bottomTooltip.usesCloseButton = NO;
        self.bottomTooltip.backgroundImage = [UIImage imageNamed:@"TooltipBottomBackground"];
        self.bottomTooltip.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.bottomTooltip];
        
        [self addHighlightAtLocation:CGPointMake(160, 160)];
        [self addHighlightAtLocation:CGPointMake(86, 239)];
        
    }
    return self;
}

- (void)addHighlightAtLocation:(CGPoint)location
{
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    highlightView.center = location;
    highlightView.frame = CGRectIntegral(highlightView.frame);
    highlightView.backgroundColor = [UIColor clearColor];
    highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    highlightView.layer.borderWidth = 1;
    
    [self.highlightViews addObject:highlightView];
    [self addSubview:highlightView];
    [highlightView release];
}

- (void)profileTooltipPressedClose:(SCHProfileTooltip *)tooltip
{
    // close the view
    [self closeView:tooltip];
}

- (void)closeView:(id)sender
{
    if (self.delegate) {
        [self.delegate profileTooltipContainerSelectedClose:self];
    }
}

@end
