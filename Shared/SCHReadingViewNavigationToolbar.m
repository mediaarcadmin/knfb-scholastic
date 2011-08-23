//
//  SCHReadingViewNavigationToolbar.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingViewNavigationToolbar.h"
#import "SCHCustomToolbar.h"

static const CGFloat kSCHReadingViewNavigationToolbarShadowHeight = 4.0f;

@interface SCHReadingViewNavigationToolbar()

@property (nonatomic, retain) UIImageView *shadowView;
@property (nonatomic, retain) SCHCustomToolbar *toolbar;
@property (nonatomic, assign) SCHReadingViewNavigationToolbarStyle style;

@property (nonatomic, retain, readonly) UIBarButtonItem *titleItem;
@property (nonatomic, retain, readonly) UILabel *titleItemLabel;

@property (nonatomic, retain, readonly) UIBarButtonItem *backItem;
@property (nonatomic, retain, readonly) UIButton *backItemButton;

@property (nonatomic, retain, readonly) UIBarButtonItem *pictureStarterItem;
@property (nonatomic, retain, readonly) UIButton *pictureStarterItemButton;

@property (nonatomic, retain, readonly) UIBarButtonItem *audioItem;
@property (nonatomic, retain, readonly) UIButton *audioItemButton;

@property (nonatomic, retain, readonly) UIBarButtonItem *helpItem;
@property (nonatomic, retain, readonly) UIButton *helpItemButton;

- (NSArray *)toolbarItemsForOrientation:(UIInterfaceOrientation)orientation;

- (UIBarButtonItem *)titleItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)backItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)pictureStarterItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)audioItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)helpItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)flexibleItem;

- (void)backItemAction:(id)selector;
- (void)pictureStarterItemAction:(id)selector;
- (void)audioItemAction:(id)selector;
- (void)helpItemAction:(id)selector;

+ (CGSize)sizeForStyle:(SCHReadingViewNavigationToolbarStyle)style orientation:(UIInterfaceOrientation)orientation;

@end

@implementation SCHReadingViewNavigationToolbar

@synthesize delegate;

@synthesize shadowView;
@synthesize toolbar;
@synthesize style;
@synthesize titleItem;
@synthesize titleItemLabel;
@synthesize backItem;
@synthesize backItemButton;
@synthesize pictureStarterItem;
@synthesize pictureStarterItemButton;
@synthesize audioItem;
@synthesize audioItemButton;
@synthesize helpItem;
@synthesize helpItemButton;


- (void)dealloc
{
    [shadowView release], shadowView = nil;
    [toolbar release], toolbar = nil;
    
    [titleItem release], titleItem = nil;
    [titleItemLabel release], titleItemLabel = nil;
    
    [backItem release], backItem = nil;
    [backItemButton release], backItemButton = nil;

    [pictureStarterItem release], pictureStarterItem = nil;
    [pictureStarterItemButton release], pictureStarterItemButton = nil;

    [audioItem release], audioItem = nil;
    [audioItemButton release], audioItemButton = nil;

    [helpItem release], helpItem = nil;
    [helpItemButton release], helpItemButton = nil;

     
    [super dealloc];
}

- (id)initWithStyle:(SCHReadingViewNavigationToolbarStyle)aStyle orientation:(UIInterfaceOrientation)orientation
{
    CGRect bounds = CGRectZero;
    bounds.size = [SCHReadingViewNavigationToolbar sizeForStyle:aStyle orientation:orientation];
    
    self = [super initWithFrame:bounds];
    if (self) {
        // Initialization code
        self.layer.anchorPoint = CGPointZero;
        self.layer.position = CGPointMake(0, 20);
        
        style = aStyle;
        
        shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reading-view-top-shadow.png"]];
        shadowView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:shadowView];
        
        toolbar = [[SCHCustomToolbar alloc] init];
        [toolbar setBackgroundImage:[[UIImage imageNamed:@"reading-view-navigation-toolbar.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];
        toolbar.contentMode = UIViewContentModeScaleToFill;
        toolbar.clipsToBounds = YES;
        [toolbar setItems:[self toolbarItemsForOrientation:orientation]];
        [self addSubview:toolbar];

    }
    return self;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    self.shadowView.frame = CGRectMake(0,
                                  CGRectGetHeight(self.bounds) - kSCHReadingViewNavigationToolbarShadowHeight,
                                  CGRectGetWidth(self.bounds),
                                  kSCHReadingViewNavigationToolbarShadowHeight);
    self.toolbar.frame = CGRectMake(0,
                               0,
                               CGRectGetWidth(self.bounds),
                               CGRectGetHeight(self.bounds) - kSCHReadingViewNavigationToolbarShadowHeight);
    
    
    [self.titleItemLabel sizeToFit];
    [self.backItemButton sizeToFit];
    [self.pictureStarterItemButton sizeToFit];
    [self.audioItemButton sizeToFit];
    [self.helpItemButton sizeToFit];
}

- (void)setTitle:(NSString *)title
{
    [self.titleItemLabel setText:title];
    [self.titleItemLabel sizeToFit];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    CGRect bounds = CGRectZero;
    bounds.size = [SCHReadingViewNavigationToolbar sizeForStyle:style orientation:orientation];
    self.bounds = bounds;
    
    [self.toolbar setItems:[self toolbarItemsForOrientation:orientation]];
}

#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!titleItem) {
        titleItemLabel = [[UILabel alloc] init];
        titleItemLabel.backgroundColor = [UIColor clearColor];
        titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleItemLabel];
    }
    
    return titleItem;
}

- (UIBarButtonItem *)backItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!backItem) {
        backItemButton = [[UIButton alloc] init];
        [backItemButton addTarget:self action:@selector(backItemAction:) forControlEvents:UIControlEventTouchUpInside];
        backItem = [[UIBarButtonItem alloc] initWithCustomView:backItemButton];        
    }
        
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [backItemButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
    } else {
        switch (self.style) {
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                [backItemButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
                break;
            default:
                [backItemButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
                break;
        }
    }
    
    return backItem;
}

- (UIBarButtonItem *)pictureStarterItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!pictureStarterItem) {
        pictureStarterItemButton = [[UIButton alloc] init];
        [pictureStarterItemButton addTarget:self action:@selector(pictureStarterItemAction:) forControlEvents:UIControlEventTouchUpInside];
        pictureStarterItem = [[UIBarButtonItem alloc] initWithCustomView:pictureStarterItemButton];        
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
    } else {
        switch (self.style) {
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
                break;
            default:
                [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
                break;
        }
    }
    
    return pictureStarterItem;
}

- (UIBarButtonItem *)audioItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!audioItem) {
        audioItemButton = [[UIButton alloc] init];
        [audioItemButton addTarget:self action:@selector(audioItemAction:) forControlEvents:UIControlEventTouchUpInside];
        audioItem = [[UIBarButtonItem alloc] initWithCustomView:audioItemButton];        
    }
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [audioItemButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
    } else {
        switch (self.style) {
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                [audioItemButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
                break;
            default:
                [audioItemButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
                break;
        }
    }
    
    return audioItem;
}

- (UIBarButtonItem *)helpItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!helpItem) {
        helpItemButton = [[UIButton alloc] init];
        [helpItemButton addTarget:self action:@selector(helpItemAction:) forControlEvents:UIControlEventTouchUpInside];
        helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpItemButton];        
    }
    
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleOlderPad:
            [helpItemButton setImage:[UIImage imageNamed:@"icon-help-older.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPad:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            [helpItemButton setImage:[UIImage imageNamed:@"icon-help-younger.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleOlderPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [helpItemButton setImage:[UIImage imageNamed:@"icon-help-older-portrait.png"] forState:UIControlStateNormal];
            } else {
                [helpItemButton setImage:[UIImage imageNamed:@"icon-help-older-landscape.png"] forState:UIControlStateNormal];
            }
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [helpItemButton setImage:[UIImage imageNamed:@"icon-help-younger-portrait.png"] forState:UIControlStateNormal];
            } else {
                [helpItemButton setImage:[UIImage imageNamed:@"icon-help-younger-landscape.png"] forState:UIControlStateNormal];
            }
            break;
    }
        
    return helpItem;
}

- (UIBarButtonItem *)flexibleItem
{
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

- (NSArray *)toolbarItemsForOrientation:(UIInterfaceOrientation)orientation
{
    NSArray *items = nil;
    
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
            items = [NSArray arrayWithObjects:
                     [self backItemForOrientation:orientation],
                     [self flexibleItem],
                     [self audioItemForOrientation:orientation],
                     [self helpItemForOrientation:orientation],
                     nil];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
            items = [NSArray arrayWithObjects:
                     [self backItemForOrientation:orientation],
                     [self flexibleItem],
                     [self pictureStarterItemForOrientation:orientation],
                     [self audioItemForOrientation:orientation],
                     [self helpItemForOrientation:orientation],
                     nil];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPad:
            items = [NSArray arrayWithObjects:
                     [self backItemForOrientation:orientation],
                     [self flexibleItem],
                     [self titleItemForOrientation:orientation],
                     [self flexibleItem],
                     [self audioItemForOrientation:orientation],
                     [self helpItemForOrientation:orientation],
                     nil];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            items = [NSArray arrayWithObjects:
                     [self backItemForOrientation:orientation],
                     [self flexibleItem],
                     [self titleItemForOrientation:orientation],
                     [self flexibleItem],
                     [self pictureStarterItemForOrientation:orientation],
                     [self audioItemForOrientation:orientation],
                     [self helpItemForOrientation:orientation],
                     nil];
            break;
        case kSCHReadingViewNavigationToolbarStyleOlderPhone:
        case kSCHReadingViewNavigationToolbarStyleOlderPad:
            items = [NSArray arrayWithObjects:
                     [self backItemForOrientation:orientation],
                     [self flexibleItem],
                     [self titleItemForOrientation:orientation],
                     [self flexibleItem],
                     [self helpItemForOrientation:orientation],
                     nil];
            break;
    }
    
    return items;
}

#pragma Toolbar Item Actions

- (void)backItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(backAction:)]) {
        [self.delegate backAction:sender];
    }
}

- (void)pictureStarterItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pictureStarterAction:)]) {
        [self.delegate pictureStarterAction:sender];
    }
}

- (void)audioItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(audioAction:)]) {
        [self.delegate audioAction:sender];
    }
}

- (void)helpItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(helpAction:)]) {
        [self.delegate helpAction:sender];
    }
}

#pragma mark - Class Methods

+ (CGSize)sizeForStyle:(SCHReadingViewNavigationToolbarStyle)aStyle orientation:(UIInterfaceOrientation)orientation
{
    
    CGSize size = CGSizeZero;

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        switch (aStyle) {
            case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
                size = CGSizeMake(320, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                size = CGSizeMake(320, 44);
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
                size = CGSizeMake(768, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                size = CGSizeMake(768, 44);
                break;
        }
    } else {
        switch (aStyle) {
            case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
                size = CGSizeMake(480, 44);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                size = CGSizeMake(480, 33);
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:    
                size = CGSizeMake(1024, 60);
                break;
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                size = CGSizeMake(1024, 44);
                break;
        }
    }
    
    size.height += kSCHReadingViewNavigationToolbarShadowHeight;
    
    return size;
}

@end
