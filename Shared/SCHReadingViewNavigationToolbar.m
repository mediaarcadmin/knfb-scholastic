//
//  SCHReadingViewNavigationToolbar.m
//  Scholastic
//
//  Created by Matt Farrugia on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingViewNavigationToolbar.h"
#import "SCHCustomToolbar.h"

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

@property (nonatomic, assign, readonly) BOOL audioItemHidden;
@property (nonatomic, assign, readonly) BOOL helpItemHidden;

- (NSArray *)toolbarItemsForOrientation:(UIInterfaceOrientation)orientation;

- (UIBarButtonItem *)titleItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)backItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)pictureStarterItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)audioItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)helpItemForOrientation:(UIInterfaceOrientation)orientation;
- (UIBarButtonItem *)flexibleItem;
- (UIBarButtonItem *)fixedItemOfWidth:(CGFloat)width;

- (IBAction)backItemAction:(id)selector;
- (IBAction)pictureStarterItemAction:(id)selector;
- (IBAction)audioItemAction:(id)selector;
- (IBAction)helpItemAction:(id)selector;

- (void)setFontSizeOfMultiLineLabel:(UILabel*)label 
                          toFitSize:(CGSize)size 
                     forMaxFontSize:(CGFloat)maxFontSize 
                     andMinFontSize:(CGFloat)minFontSize 
           startCharacterWrapAtSize:(CGFloat)characterWrapSize;

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
@synthesize audioItemHidden;
@synthesize helpItemHidden;

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

- (id)initWithStyle:(SCHReadingViewNavigationToolbarStyle)aStyle 
              audio:(BOOL)showAudio 
               help:(BOOL)showHelp
        orientation:(UIInterfaceOrientation)orientation
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
        
        audioItemHidden = !showAudio;
        helpItemHidden = !showHelp;
        
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
    
    CGRect titleBounds = self.titleItemLabel.bounds;
    titleBounds.size.height = CGRectGetHeight(self.toolbar.bounds);
    titleBounds = CGRectInset(titleBounds, 0, 4);
    
    [self setFontSizeOfMultiLineLabel:self.titleItemLabel
                            toFitSize:titleBounds.size
                       forMaxFontSize:self.titleItemLabel.font.pointSize
                       andMinFontSize:self.titleItemLabel.minimumFontSize
             startCharacterWrapAtSize:self.titleItemLabel.minimumFontSize];
    
    [self.backItemButton sizeToFit];
    [self.pictureStarterItemButton sizeToFit];
    [self.audioItemButton sizeToFit];
    [self.helpItemButton sizeToFit];
}

- (void)setTitle:(NSString *)title
{
    [self.titleItemLabel setText:title];
}

- (void)setAudioItemActive:(BOOL)active
{
    [self.audioItemButton setSelected:active];
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
        titleItemLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0f];
        titleItemLabel.numberOfLines = 2;
        titleItemLabel.minimumFontSize = 9.0f;
        titleItemLabel.adjustsFontSizeToFitWidth = YES;
        titleItemLabel.textAlignment = UITextAlignmentCenter;
        titleItemLabel.backgroundColor = [UIColor clearColor];
        titleItem = [[UIBarButtonItem alloc] initWithCustomView:titleItemLabel];
    }
    
    CGRect titleBounds = titleItemLabel.bounds;
    titleBounds.origin = CGPointZero;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        switch (self.style) {
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                titleBounds.size.width = 200;
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                titleBounds.size.width = 320;
                break;
            default:
                break;
        }
    } else {
        switch (self.style) {
            case kSCHReadingViewNavigationToolbarStyleOlderPhone:
                titleBounds.size.width = 360;
                break;
            case kSCHReadingViewNavigationToolbarStyleYoungerPad:
            case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            case kSCHReadingViewNavigationToolbarStyleOlderPad:
                titleBounds.size.width = 588;
                break;
            default:
                break;
        }
    }
    
    titleItemLabel.frame = titleBounds;
    
    return titleItem;
}

- (UIBarButtonItem *)backItemForOrientation:(UIInterfaceOrientation)orientation
{
    if (!backItem) {
        backItemButton = [[UIButton alloc] init];
        [backItemButton addTarget:self action:@selector(backItemAction:) forControlEvents:UIControlEventTouchUpInside];
        backItem = [[UIBarButtonItem alloc] initWithCustomView:backItemButton];        
    }
        
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleOlderPad:
            [backItemButton setImage:[UIImage imageNamed:@"icon-back-older.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPad:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            [backItemButton setImage:[UIImage imageNamed:@"icon-back-younger.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleOlderPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [backItemButton setImage:[UIImage imageNamed:@"icon-back-older-portrait.png"] forState:UIControlStateNormal];
            } else {
                [backItemButton setImage:[UIImage imageNamed:@"icon-back-older-landscape.png"] forState:UIControlStateNormal];
            }
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [backItemButton setImage:[UIImage imageNamed:@"icon-back-younger-portrait.png"] forState:UIControlStateNormal];
            } else {
                [backItemButton setImage:[UIImage imageNamed:@"icon-back-younger-landscape.png"] forState:UIControlStateNormal];
            }
            break;
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
    
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-picturestarter-younger.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-picturestarter-younger-portrait.png"] forState:UIControlStateNormal];
            } else {
                [pictureStarterItemButton setImage:[UIImage imageNamed:@"icon-picturestarter-younger-landscape.png"] forState:UIControlStateNormal];
            }
            break;
        default:
            break;
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
    
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleYoungerPad:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
            [audioItemButton setImage:[UIImage imageNamed:@"icon-audio-younger.png"] forState:UIControlStateNormal];
            break;
        case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                [audioItemButton setImage:[UIImage imageNamed:@"icon-audio-younger-portrait.png"] forState:UIControlStateNormal];
            } else {
                [audioItemButton setImage:[UIImage imageNamed:@"icon-audio-younger-landscape.png"] forState:UIControlStateNormal];
            }
            break;
        default:
            break;
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

- (UIBarButtonItem *)fixedItemOfWidth:(CGFloat)width
{
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    item.width = width;
    
    return item;
}

- (NSArray *)toolbarItemsForOrientation:(UIInterfaceOrientation)orientation
{
    NSMutableArray *items = [NSMutableArray array];
    
    switch (self.style) {
        case kSCHReadingViewNavigationToolbarStyleYoungerPhone:
        {
            [items addObject:[self backItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];

            if (!self.audioItemHidden) {
                [items addObject:[self audioItemForOrientation:orientation]];
            }
            
            if (!self.audioItemHidden && !self.helpItemHidden) {
                [items addObject:[self flexibleItem]];
            }
            
            if (!self.helpItemHidden) {
                [items addObject:[self helpItemForOrientation:orientation]];
            }

            break;
        }
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone:
        {
            [items addObject:[self backItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];
            [items addObject:[self pictureStarterItemForOrientation:orientation]];
            
            if (!self.audioItemHidden) {
                [items addObject:[self flexibleItem]];
                [items addObject:[self audioItemForOrientation:orientation]];
            }
            
            if (!self.helpItemHidden) {
                [items addObject:[self flexibleItem]];
                [items addObject:[self helpItemForOrientation:orientation]];
            }
            
            break;
        }
        case kSCHReadingViewNavigationToolbarStyleYoungerPad:
        {
            [items addObject:[self backItemForOrientation:orientation]];
            [items addObject:[self fixedItemOfWidth:48]];
            [items addObject:[self flexibleItem]];
            [items addObject:[self titleItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];
            
            if (!self.audioItemHidden) {
                [items addObject:[self audioItemForOrientation:orientation]];
            }
            
            if (!self.audioItemHidden && !self.helpItemHidden) {
                [self fixedItemOfWidth:12];
            } else if (!self.audioItemHidden && self.helpItemHidden) {
                [self fixedItemOfWidth:48];
            } else if (self.audioItemHidden && !self.helpItemHidden) {
                [self fixedItemOfWidth:48];
            } 
            
            if (!self.helpItemHidden) {
                [items addObject:[self helpItemForOrientation:orientation]];
            }

            break;
        }
        case kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad:
        {
            [items addObject:[self backItemForOrientation:orientation]];
            
            if (self.audioItemHidden) {
                [items addObject:[self fixedItemOfWidth:116]];
            } else {
                [items addObject:[self fixedItemOfWidth:124]];
            }
            
            [items addObject:[self flexibleItem]];
            [items addObject:[self titleItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];
            
            if (self.audioItemHidden) {
                [items addObject:[self fixedItemOfWidth:61]];
            } else {
                [items addObject:[self audioItemForOrientation:orientation]];
                [items addObject:[self fixedItemOfWidth:9]];
            }
            
            [items addObject:[self pictureStarterItemForOrientation:orientation]];
            
            if (!self.helpItemHidden) {
                [items addObject:[self fixedItemOfWidth:12]];
                [items addObject:[self helpItemForOrientation:orientation]];
            }
             
            break;
        }
        case kSCHReadingViewNavigationToolbarStyleOlderPhone:
        case kSCHReadingViewNavigationToolbarStyleOlderPad:
        {
            [items addObject:[self backItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];
            [items addObject:[self titleItemForOrientation:orientation]];
            [items addObject:[self flexibleItem]];
            
            if (self.helpItemHidden) {
                [items addObject:[self fixedItemOfWidth:48]];
            } else {
                [items addObject:[self helpItemForOrientation:orientation]];
            }

            break;
        }
    }
    
    [self.audioItemButton setHidden:self.audioItemHidden];
    [self.helpItemButton setHidden:self.helpItemHidden];
    
    return [NSArray arrayWithArray:items];
}

#pragma Toolbar Item Actions

- (IBAction)backItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(backAction:)]) {
        [self.delegate backAction:sender];
    }
}

- (IBAction)pictureStarterItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pictureStarterAction:)]) {
        [self.delegate pictureStarterAction:sender];
    }
}

- (IBAction)audioItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(audioAction:)]) {
        [self.delegate audioAction:sender];
    }
}

- (IBAction)helpItemAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(helpAction:)]) {
        [self.delegate helpAction:sender];
    }
}

- (void)setFontSizeOfMultiLineLabel:(UILabel*)label 
                         toFitSize:(CGSize)size 
                    forMaxFontSize:(CGFloat)maxFontSize 
                    andMinFontSize:(CGFloat)minFontSize 
          startCharacterWrapAtSize:(CGFloat)characterWrapSize
{
    CGRect constraintSize = CGRectMake(0, 0, size.width, 0);
    label.frame = constraintSize;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0; // allow any number of lines
    
    for (int i = maxFontSize; i > minFontSize; i--) {
        
        if((i < characterWrapSize) && (label.lineBreakMode == UILineBreakModeWordWrap)){
            // start over again with lineBreakeMode set to character wrap 
            i = maxFontSize;
            label.lineBreakMode = UILineBreakModeCharacterWrap;
        }
        
        label.font = [label.font fontWithSize:i];
        [label sizeToFit];
        if(label.frame.size.height < size.height){
            break;
        }       
        label.frame = constraintSize;
    } 
}

- (CGRect)toolbarFrame
{
    return self.toolbar.frame;
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
