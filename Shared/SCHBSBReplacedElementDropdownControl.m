//
//  SCHBSBReplacedElementDropdownControl.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementDropdownControl.h"
#import <libEucalyptus/THRoundRects.h>

@interface SCHBSBReplacedElementDropdownControl() <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UIButton *dropdownButton;
@property (nonatomic, assign) CGFloat constrainedWidth;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, copy) NSArray *dropdownItems;
@property (nonatomic, retain) UIImage *defaultUnselectedDropdownImage;
@property (nonatomic, retain) UIImage *defaultSelectedDropdownImage;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UIPopoverController *popover;

+ (CGRect)containerBoundsWithFont:(UIFont *)font forWidth:(CGFloat)width item:(NSString *)item;

@end;

static const CGFloat SCHBSBReplacedElementDropdownXPadding = 16.0f;
static const CGFloat SCHBSBReplacedElementDropdownYPadding = 5.0f;
static const CGFloat SCHBSBReplacedElementDropdownGraphicSpanRatio = 0.6f;
static const CGFloat SCHBSBReplacedElementDropdownButtonMinimumSpan = 32.0f;
static const CGFloat SCHBSBReplacedElementDropdownButtonCornerRadius = 5.0f;

@implementation SCHBSBReplacedElementDropdownControl

@synthesize dropdownButton;
@synthesize constrainedWidth;
@synthesize font;
@synthesize dropdownItems;
@synthesize defaultUnselectedDropdownImage;
@synthesize defaultSelectedDropdownImage;
@synthesize pickerView;
@synthesize popover;

- (void)dealloc
{
    [dropdownButton release], dropdownButton = nil;
    [font release], font = nil;
    [dropdownItems release], dropdownItems = nil;
    [defaultUnselectedDropdownImage release], defaultUnselectedDropdownImage = nil;
    [defaultSelectedDropdownImage release], defaultSelectedDropdownImage = nil;
    [pickerView release], pickerView = nil;
    
    if ([popover isPopoverVisible]) {
        [popover dismissPopoverAnimated:YES];
    }
    
    [popover release], popover = nil;
    
    [super dealloc];
}

- (id)initWithFont:(UIFont *)aFont width:(CGFloat)width items:(NSArray *)items;
{
    self = [super init];
    if (self) {
        // Initialization code        
        constrainedWidth = width;
        font = [aFont retain];
        CGSize defaultSize = [SCHBSBReplacedElementDropdownControl sizeWithFont:font forWidth:width items:items];
        CGRect defaultFrame = CGRectZero;
        defaultFrame.size = defaultSize;
        self.frame = defaultFrame;
        self.clipsToBounds = NO;
        
        dropdownItems = [items copy];
        
        dropdownButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        dropdownButton.frame = self.bounds;
        
        dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(SCHBSBReplacedElementDropdownYPadding, SCHBSBReplacedElementDropdownXPadding, SCHBSBReplacedElementDropdownYPadding, SCHBSBReplacedElementDropdownXPadding + SCHBSBReplacedElementDropdownButtonMinimumSpan);
        [[dropdownButton titleLabel] setFont:font];
        [[dropdownButton titleLabel] setFont:font];
        [[dropdownButton titleLabel] setFont:font];
        [dropdownButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dropdownButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        [dropdownButton addTarget:self action:@selector(displayDropdown:) forControlEvents:UIControlEventTouchUpInside];
        [dropdownButton addTarget:self action:@selector(dropdownItemDepressed:) forControlEvents:UIControlEventTouchDown];
        [dropdownButton setBackgroundImage:self.defaultUnselectedDropdownImage forState:UIControlStateNormal];
        [dropdownButton setBackgroundImage:self.defaultUnselectedDropdownImage forState:UIControlStateSelected];
        
        [self addSubview:dropdownButton];
        
        [self setSelectedItemIndex:SCHBSBReplacedElementDropdownControlNoItem];
    }
    return self;
}

- (UIImage *)defaultSelectedDropdownImage
{
    if (!defaultSelectedDropdownImage) {
        CGFloat graphicSpan = SCHBSBReplacedElementDropdownButtonMinimumSpan;
        CGRect graphicRect = CGRectMake(0, 0, graphicSpan, graphicSpan);
        
        UIGraphicsBeginImageContextWithOptions(graphicRect.size, NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, graphicRect);
        CGRect elipseBounds = CGRectInset(graphicRect, 1.0f, 1.0f);
        
        CGContextSaveGState(ctx);
        CGContextBeginPath(ctx);
        CGContextAddEllipseInRect(ctx, elipseBounds);
        CGContextClip(ctx);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        
        NSArray *colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.2f].CGColor, nil];
        
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(elipseBounds), CGRectGetMinY(elipseBounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(elipseBounds), CGRectGetMaxY(elipseBounds));
        
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        CGContextRestoreGState(ctx);
        
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.7f);
        CGContextSetLineWidth(ctx, 1.5f);
        CGContextStrokeEllipseInRect(ctx, elipseBounds);
        
        defaultSelectedDropdownImage = UIGraphicsGetImageFromCurrentImageContext();
        [defaultSelectedDropdownImage retain];
        
        UIGraphicsEndImageContext();
    }
    
    return defaultSelectedDropdownImage;
}

- (UIImage *)defaultUnselectedDropdownImage
{
    if (!defaultUnselectedDropdownImage) {
        CGFloat graphicSpan = MAX(SCHBSBReplacedElementDropdownButtonMinimumSpan, self.bounds.size.height);
        CGFloat cornerRadius = SCHBSBReplacedElementDropdownButtonCornerRadius;
        CGFloat stretchX = 1;
        CGFloat stretchY = 0;
        
        CGFloat spanX = (graphicSpan + cornerRadius) * 2 + stretchX;
        CGFloat spanY = graphicSpan + cornerRadius * 2 + stretchY;
        CGRect graphicRect = CGRectMake(0, 0, spanX, spanY);
        
        UIGraphicsBeginImageContextWithOptions(graphicRect.size, NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, graphicRect);
        
        CGRect roundedRect = CGRectInset(graphicRect, 0.5f, 0.5f);
        CGFloat radius = MIN(roundedRect.size.width * 0.5f, roundedRect.size.height * 0.5f);
        radius = MIN(cornerRadius, radius);
                
        CGContextSaveGState(ctx);
        CGContextBeginPath(ctx);
        THAddRoundedRectToPath(ctx, roundedRect, radius, radius);
        CGContextClip(ctx);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        
        NSArray *backColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.2f].CGColor, nil];
        NSArray *buttonColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.1f alpha:0.5f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.76f].CGColor, nil];
        
        CGGradientRef backGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) backColors, locations);
        CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) buttonColors, locations);
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(roundedRect), CGRectGetMinY(roundedRect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(roundedRect), CGRectGetMaxY(roundedRect));
        
        CGContextDrawLinearGradient(ctx, backGradient, startPoint, endPoint, 0);
        
        CGRect buttonBounds = CGRectMake(graphicSpan + cornerRadius + stretchX, 0, graphicSpan + cornerRadius, spanY);
        CGContextAddRect(ctx, buttonBounds);
        CGContextClip(ctx);
        CGContextDrawLinearGradient(ctx, buttonGradient, startPoint, endPoint, 0);

        CGContextRestoreGState(ctx);
        
        CGRect triangleBounds = CGRectInset(buttonBounds, buttonBounds.size.width * (0.5 * SCHBSBReplacedElementDropdownGraphicSpanRatio), 0);
        triangleBounds.size.height = CGRectGetWidth(triangleBounds);
        triangleBounds.origin.y = floorf((CGRectGetHeight(buttonBounds) - CGRectGetHeight(triangleBounds))/2.0f);
        
         CGContextSaveGState(ctx);
        CGContextSetRGBFillColor(ctx, 1, 0,1, 0.7f);
         CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1.5f), 0, [UIColor colorWithWhite:0 alpha:0.7f].CGColor);
         CGContextBeginTransparencyLayer(ctx, NULL);
         CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, triangleBounds.origin.x, CGRectGetMinY(triangleBounds));
        CGContextAddLineToPoint(ctx, CGRectGetMidX(triangleBounds), CGRectGetMaxY(triangleBounds));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(triangleBounds), CGRectGetMinY(triangleBounds));
        CGContextClosePath(ctx);
        CGContextClip(ctx);
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
        CGContextFillRect(ctx, buttonBounds);
        CGContextDrawLinearGradient(ctx, backGradient, startPoint, endPoint, 0);
        CGContextEndTransparencyLayer(ctx);
        CGContextRestoreGState(ctx);
              
        CGContextSaveGState(ctx);
        CGContextSetRGBStrokeColor(ctx, 1, 0,1, 0.7f);
        CGContextSetLineWidth(ctx, 1.5f);
         CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, graphicSpan + cornerRadius + stretchX + 1, CGRectGetMinY(graphicRect));
        CGContextAddLineToPoint(ctx, graphicSpan + cornerRadius + stretchX + 1, CGRectGetMaxY(graphicRect));
        CGContextClipToRect(ctx, buttonBounds);

        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);
        
        CGContextBeginPath(ctx);
        THAddRoundedRectToPath(ctx, roundedRect, radius, radius);
        //addDropdownRoundedRectToPath(ctx, cornerRadius, graphicRect);
        CGContextClosePath(ctx);
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.7f);
        CGContextSetLineWidth(ctx, 1.0f);
        CGContextStrokePath(ctx);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        defaultUnselectedDropdownImage = [image stretchableImageWithLeftCapWidth:graphicSpan + cornerRadius topCapHeight:0];
        [defaultUnselectedDropdownImage retain];
        
        UIGraphicsEndImageContext();
    }
    
    return defaultUnselectedDropdownImage;
}

- (NSUInteger)numberOfItems
{
    return [self.dropdownItems count];
}

- (NSInteger)selectedItemIndex
{
    NSInteger ret = SCHBSBReplacedElementDropdownControlNoItem;
    
    // N.B. This doesn't allow for duplicate entries
    for (NSString *item in self.dropdownItems) {
        if ([item isEqualToString:[[self.dropdownButton titleLabel] text]]) {
            ret = [self.dropdownItems indexOfObject:item];
            break;
        }
    }
    
    return ret;
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex
{
    if (selectedItemIndex >= 0 && selectedItemIndex < [self.dropdownItems count]) {
        [self.dropdownButton setTitle:[self.dropdownItems objectAtIndex:selectedItemIndex] forState:UIControlStateNormal];
    } else {
        [self.dropdownButton setTitle:@"Choose One" forState:UIControlStateNormal];
    }
}

- (void)setTitle:(NSString *)title forItemAtIndex:(NSUInteger)index
{
    if (index < [self.dropdownItems count]) {
        BOOL updateValue = [self selectedItemIndex] == index;

        NSMutableArray *mutableItems = [self.dropdownItems mutableCopy];
        [mutableItems removeObjectAtIndex:index];
        [mutableItems insertObject:title atIndex:index];
        self.dropdownItems = mutableItems;
        [mutableItems release];
        
        if (updateValue) {
            [self setSelectedItemIndex:index];
        }
    }
}

- (NSString *)titleForItemAtIndex:(NSUInteger)index
{
    NSString *ret = nil;
    
    if (index < [self.dropdownItems count]) {
        ret = [self.dropdownItems objectAtIndex:index];
    }
    
    return ret;
}

#pragma mark - Item events

//- (void)dropdownItemSelected:(UIControl *)sender
//{
//    NSInteger index = [self.radioArray indexOfObject:sender];
//    
//    [self setSelectedButtonIndex:index];
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
//}


- (void)dropdownItemDepressed:(UIControl *)sender
{
    //NSLog(@"Depressed button!");
    // Noop - could add a blur here
}

- (void)displayDropdown:(UIControl *)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self becomeFirstResponder];
        [self.pickerView selectRow:self.selectedItemIndex inComponent:0 animated:NO];
    } else {
        UITableViewController *viewController = [[[UITableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        viewController.tableView.delegate = self;
        viewController.tableView.dataSource = self;
        viewController.contentSizeForViewInPopover = CGSizeMake(320, 44 * [self.dropdownItems count]);
        
        if (![self.popover isPopoverVisible]) {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
            [self.popover presentPopoverFromRect:sender.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown animated:YES];
        }
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputView
{
    self.pickerView = [[[UIPickerView alloc] init] autorelease];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.pickerView setShowsSelectionIndicator:YES];
    
    return self.pickerView;
}

- (UIView *)inputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -44, 320, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *done = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)] autorelease];
    UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    [toolbar setItems:[NSArray arrayWithObjects:spacer, done, nil]];
    return [toolbar autorelease];
}

- (void)endEditing:(BOOL)forced
{
    [super endEditing:forced];
    if ([self.popover isPopoverVisible]) {
        [self.popover dismissPopoverAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dropdownItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DropdownCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.dropdownItems objectAtIndex:[indexPath row]];
    
    if (self.selectedItemIndex == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedItemIndex:[indexPath row]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [tableView reloadData];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)aPickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dropdownItems count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.dropdownItems objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setSelectedItemIndex:row];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Class methods

+ (CGRect)containerBoundsWithFont:(UIFont *)font forWidth:(CGFloat)width item:(NSString *)item
{
    CGFloat graphicSpan = SCHBSBReplacedElementDropdownButtonMinimumSpan;
    UIEdgeInsets labelInsets = UIEdgeInsetsMake(SCHBSBReplacedElementDropdownYPadding, SCHBSBReplacedElementDropdownXPadding, SCHBSBReplacedElementDropdownYPadding, SCHBSBReplacedElementDropdownXPadding + SCHBSBReplacedElementDropdownButtonMinimumSpan);
     
    CGSize labelSize = [item sizeWithFont:font forWidth:width - labelInsets.left - labelInsets.right - graphicSpan lineBreakMode:UILineBreakModeWordWrap];
    graphicSpan = MIN(labelSize.height, SCHBSBReplacedElementDropdownButtonMinimumSpan);
    return CGRectMake(0, 0, MIN(labelSize.width + labelInsets.left + labelInsets.right + graphicSpan, width), MAX(labelSize.height + labelInsets.top + labelInsets.bottom, graphicSpan));
}

+ (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width items:(NSArray *)items
{
    CGSize totalSize = CGSizeMake(0, 0);

    for (NSString *item in items) {
        CGSize itemSize = [SCHBSBReplacedElementDropdownControl containerBoundsWithFont:font forWidth:width item:item].size;
        totalSize.height = MAX(totalSize.height, itemSize.height);
        totalSize.width  = MAX(totalSize.width, itemSize.width);
    }
    
    return totalSize;
}

@end
