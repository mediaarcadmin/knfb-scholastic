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

@end

@implementation SCHProfileTooltipContainer

@synthesize delegate;
@synthesize clearBackgroundButton;
@synthesize topTooltip;
@synthesize bottomTooltip;

- (void)dealloc
{
    delegate = nil;
    [clearBackgroundButton release], clearBackgroundButton = nil;
    [topTooltip release], topTooltip = nil;
    [bottomTooltip release], bottomTooltip = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clearBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.clearBackgroundButton.backgroundColor = [UIColor clearColor];
        [self.clearBackgroundButton addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.clearBackgroundButton];
        
        self.bottomTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(0, 320, 320, 160)] autorelease];
        [self.bottomTooltip setFirstTitle:@"Reading Manager"
                            firstBodyText:@"Go here to assign new eBooks and monitor reading progress."
                              secondTitle:@"Child's Bookshelf"
                           secondBodyText:@"Your child can start reading by selecting their name. Their eBooks will be waiting for them!"];
        self.topTooltip.usesCloseButton = NO;
        [self addSubview:self.bottomTooltip];
        
        self.topTooltip = [[[SCHProfileTooltip alloc] initWithFrame:CGRectMake(0, 0, 320, 100)] autorelease];
        [self.topTooltip setTitle:@"Welcome to your Bookshelves!"
                         bodyText:@"Manage individual bookshelves for your children. You’ll need to assign each eBook to a bookshelf before they be read."];
        self.topTooltip.usesCloseButton = YES;
        self.topTooltip.delegate = self;
        [self addSubview:self.topTooltip];
        
        
    }
    return self;
}

- (void)profileTooltipPressedClose:(SCHProfileTooltip *)tooltip
{
    // close the view
    [self closeView:tooltip];
}

- (void)closeView:(id)sender
{
    
}

@end
