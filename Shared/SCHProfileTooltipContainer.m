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

@property (nonatomic, retain) UIImage *cachedSuperviewImage;

@end

@implementation SCHProfileTooltipContainer

@synthesize delegate;
@synthesize clearBackgroundButton;
@synthesize topTooltip;
@synthesize bottomTooltip;
@synthesize highlightViews;
@synthesize cachedSuperviewImage;

- (void)dealloc
{
    delegate = nil;
    [clearBackgroundButton release], clearBackgroundButton = nil;
    [topTooltip release], topTooltip = nil;
    [bottomTooltip release], bottomTooltip = nil;
    [highlightViews release], highlightViews = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame numberOfBookshelves:(NSUInteger)numberOfBookshelves showReadingManagerOnly:(BOOL)showReadingManagerOnly
{
    CGFloat xOffset = 0;
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.highlightViews = [NSMutableArray array];

        self.clearBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.clearBackgroundButton.frame = frame;
        self.clearBackgroundButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.clearBackgroundButton.backgroundColor = [UIColor clearColor];
        [self.clearBackgroundButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearBackgroundButton];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (numberOfBookshelves == 1) {
                xOffset = 74;
            }
            
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
            [self addHighlightAtLocation:CGPointMake(86 + xOffset, 239)];
            
        } else {
            if (numberOfBookshelves == 1) {
                xOffset = 266;
            } else if (numberOfBookshelves == 2) {
                xOffset = 133;
            }
            
            if ( showReadingManagerOnly ) {
                self.topTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(364, 262, 315, 119) edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)] autorelease];
                self.topTooltip.usesCloseButton = NO;
                self.topTooltip.backgroundImage = [UIImage imageNamed:@"TooltipReadingManagerBackground"]; 
            }
            else {
                self.topTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(599, 172, 315, 165) edgeInsets:UIEdgeInsetsMake(-5, 20, 0, 0)] autorelease];
                [self.topTooltip setTitle:@"Reading Manager"
                                     bodyText:@"Go back to the Reading Manager to create new bookshelves,  assign new eBooks, or see reports on reading progress. This area is password protected and only accessible to grown-ups."];
                self.topTooltip.usesCloseButton = YES;
                self.topTooltip.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
                self.topTooltip.backgroundImage = [UIImage imageNamed:@"TooltipTopBackground"];
                
                self.bottomTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(102 + xOffset, 388, 301, 132)
                                                                    edgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)] autorelease];
                [self.bottomTooltip setTitle:@"Child's Bookshelf"
                                    bodyText:@"Each child can start reading by selecting his or her name.  The eBooks you assigned are waiting for them!"];
                self.bottomTooltip.usesCloseButton = NO;
                self.bottomTooltip.backgroundImage = [UIImage imageNamed:@"TooltipBottomBackground"];
                self.bottomTooltip.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                [self addSubview:self.bottomTooltip];
                [self addHighlightAtLocation:CGPointMake(248 + xOffset, 358)];
            }
            self.topTooltip.delegate = self;
            [self addSubview:self.topTooltip];
            
            // reading manager highlight
            [self addHighlightAtLocation:CGPointMake(514, 250)];
        }
    }
    return self;
}

- (void)addHighlightAtLocation:(CGPoint)location
{
    CGRect highlightFrame = CGRectMake(0, 0, 77, 77);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        highlightFrame = CGRectMake(0, 0, 110, 110);
    }
    
    UIView *highlightView = [[UIView alloc] initWithFrame:highlightFrame];
    highlightView.center = location;
    highlightView.frame = CGRectIntegral(highlightView.frame);
    
    highlightView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TooltipHighlight"]];
    imageView.frame = highlightFrame;
    imageView.backgroundColor = [UIColor clearColor];
    [highlightView addSubview:imageView];
    [imageView release];
    
    [self.highlightViews addObject:highlightView];
    [self addSubview:highlightView];
    [self sendSubviewToBack:highlightView];
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
