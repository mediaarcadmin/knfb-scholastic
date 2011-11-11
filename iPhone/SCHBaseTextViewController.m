//
//  SCHBaseTextViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBaseTextViewController.h"
#import "SCHCustomToolbar.h"

@interface SCHBaseTextViewController()

- (void)setCloseButtonHidden:(BOOL)hidden;

@end

@implementation SCHBaseTextViewController

@synthesize titleLabel;
@synthesize textView;
@synthesize topToolbar;
@synthesize closeButton;
@synthesize spacer;
@synthesize shouldHideCloseButton;

- (id)init
{
    self = [super initWithNibName:@"SCHBaseTextViewController" bundle:nil];
    return self;
}

- (void)releaseViewObjects
{
    self.titleLabel = nil;
    self.textView.delegate = nil;
    self.textView = nil;
    self.topToolbar = nil;
    self.closeButton = nil;
    self.spacer = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidLoad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"settings-ipad-top-toolbar"]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.title;
    
    [self setCloseButtonHidden:self.shouldHideCloseButton];
}

- (void)setCloseButtonHidden:(BOOL)hidden
{    
    NSAssert(self.closeButton, @"closeButton outlet must be set before shouldHideCloseButton is called");
    NSAssert(self.spacer, @"spacer outlet must be set before shouldHideCloseButton is called");

    NSMutableArray *items = [[[self.topToolbar items] mutableCopy] autorelease];
    
    if (hidden) {
        if ([items containsObject:self.closeButton] && 
            [items containsObject:self.spacer]) {
            [items removeObject:self.spacer];
            [items removeObject:self.closeButton];
        }
    } else {
        if (![items containsObject:self.closeButton] && 
            ![items containsObject:self.spacer]) {
            [items insertObject:self.closeButton atIndex:0];
            [items addObject:self.spacer];
        }
    }
    
    [self.topToolbar setItems:items animated:NO];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
