//
//  SCHBSBReplacedElementRadioControl.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementRadioControl.h"

@interface SCHBSBReplacedElementRadioControl()

@property (nonatomic, assign) CGFloat constrainedWidth;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) NSMutableArray *buttonArray;
@property (nonatomic, retain) NSMutableArray *labelArray;
@property (nonatomic, retain) NSMutableArray *radioArray;
@property (nonatomic, retain) UIImage *defaultUnselectedRadioImage;
@property (nonatomic, retain) UIImage *defaultSelectedRadioImage;

- (void)insertRadioItem:(NSString *)item atIndex:(NSUInteger)index;
+ (CGRect)containerBoundsWithFont:(UIFont *)font forWidth:(CGFloat)width item:(NSString *)item;

@end;

static const CGFloat SCHBSBReplacedElementRadioItemPadding = 2.0f;
static const CGFloat SCHBSBReplacedElementRadioGutterPadding = 5.0f;
static const CGFloat SCHBSBReplacedElementRadioRightPadding = 5.0f;
static const CGFloat SCHBSBReplacedElementRadioGraphicSpan = 26.0f;

@implementation SCHBSBReplacedElementRadioControl

@synthesize constrainedWidth;
@synthesize font;
@synthesize labelArray;
@synthesize buttonArray;
@synthesize radioArray;
@synthesize defaultUnselectedRadioImage;
@synthesize defaultSelectedRadioImage;

- (void)dealloc
{
    [font release], font = nil;
    [buttonArray release], buttonArray = nil;
    [labelArray release], labelArray = nil;
    [radioArray release], radioArray = nil;
    [defaultUnselectedRadioImage release], defaultUnselectedRadioImage = nil;
    [defaultSelectedRadioImage release], defaultSelectedRadioImage = nil;
    
    [super dealloc];
}

- (id)initWithFont:(UIFont *)aFont width:(CGFloat)width items:(NSArray *)items;
{
    self = [super init];
    if (self) {
        // Initialization code
        constrainedWidth = width;
        font = [aFont retain];
        CGSize defaultSize = [SCHBSBReplacedElementRadioControl sizeWithFont:font forWidth:width items:items];
        CGRect defaultFrame = CGRectZero;
        defaultFrame.size = defaultSize;
        self.frame = defaultFrame;
        self.clipsToBounds = NO;
        
        buttonArray = [[NSMutableArray alloc] initWithCapacity:[items count]];
        labelArray = [[NSMutableArray alloc] initWithCapacity:[items count]];
        radioArray = [[NSMutableArray alloc] initWithCapacity:[items count]];
        
        for (int i = 0; i < [items count]; i++) {
            NSString *item = [items objectAtIndex:i];
            [self insertRadioItem:item atIndex:i];
        }
                
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat radioSpan = SCHBSBReplacedElementRadioGraphicSpan;
    CGFloat itemPadding = SCHBSBReplacedElementRadioItemPadding;
    CGFloat gutterPadding = SCHBSBReplacedElementRadioGutterPadding;
    CGFloat rightPadding = SCHBSBReplacedElementRadioRightPadding;
    
    CGSize initialSize = [SCHBSBReplacedElementRadioControl sizeWithFont:self.font forWidth:self.constrainedWidth items:[self.labelArray valueForKey:@"text"]];
    CGFloat initialHeight = initialSize.height;
    CGFloat initialWidth = initialSize.width;
    
    CGFloat newHeight = CGRectGetHeight([self bounds]);
    CGFloat newWidth = CGRectGetWidth([self bounds]);
    
    CGFloat heightScale = 1;
    CGFloat widthScale = 1;
    
    if (initialHeight > 0) {
        heightScale = newHeight / initialHeight;
    }
    
    if (initialWidth > 0) {
        widthScale = newWidth / initialWidth;
    }
    
    CGFloat maxLabelWidth = 0;
    CGFloat maxY = 0;
    
    for (UIView *container in self.radioArray) {
        UILabel *label = (UILabel *)[container viewWithTag:1];
        
        // Don't scale the radioSpan or the rightPadding
        CGFloat labelSpan = self.constrainedWidth - radioSpan - gutterPadding - rightPadding;
        CGFloat scaledLabelSpan = labelSpan * widthScale;
        
        CGSize unscaledContainerSize = [SCHBSBReplacedElementRadioControl containerBoundsWithFont:self.font forWidth:self.constrainedWidth item:label.text].size;
        CGRect newFrame = CGRectMake(0, maxY, newWidth, unscaledContainerSize.height * heightScale);
        container.frame = newFrame;
        maxY = CGRectGetMaxY(newFrame);
        
        // Ask Jamie why there is a scale factor applied when we passed in the correct font size at creation time and are using the same one now? Essentially, how come when I tell it the size I want to be for medium, it makes me bigger or smaller?
        CGFloat yOffset = newFrame.origin.y - floorf(newFrame.origin.y);
        CGSize labelSize = [label.text sizeWithFont:self.font forWidth:scaledLabelSpan lineBreakMode:UILineBreakModeWordWrap];
        
        if (labelSize.width == 0) {
            // This didn't fit, caluclate the fit constrained to the container frame
            labelSize = [label.text sizeWithFont:self.font constrainedToSize:newFrame.size lineBreakMode:UILineBreakModeWordWrap];
        }

        CGFloat newLabelY = floorf((newFrame.size.height - labelSize.height)/2.0f) - yOffset;
        CGRect newLabelFrame = CGRectMake(0, newLabelY, labelSize.width, labelSize.height);
        
        label.frame = newLabelFrame;
        maxLabelWidth = MAX(maxLabelWidth, newLabelFrame.size.width);
    }
    
    for (UIView *container in self.radioArray) {
        CGRect newFrame = container.frame;
        
        CGFloat yOffset = newFrame.origin.y - floorf(newFrame.origin.y);
        CGFloat scaledGutterPadding = gutterPadding * widthScale;
        
        UIView *label = [container viewWithTag:1];
        CGRect newLabelFrame = label.frame;
        CGFloat scaledItemPadding = ceilf(itemPadding * heightScale);
        
        CGFloat newButtonWidth = MIN(MIN(radioSpan, newFrame.size.width - maxLabelWidth), newFrame.size.height);
        CGFloat newLabelX = ceilf(MIN(newFrame.size.width - maxLabelWidth - rightPadding, newButtonWidth + scaledGutterPadding));
        newLabelFrame.origin.x = newLabelX;
        
        label.frame = newLabelFrame;
        
        UIView *button = [container viewWithTag:2];
        CGFloat buttonSpan = MIN(newButtonWidth, newFrame.size.height - 2 * scaledItemPadding);
        CGFloat newButtonY = ceilf((newFrame.size.height - buttonSpan)/2.0f) - yOffset;
        button.frame = CGRectMake(0, newButtonY, buttonSpan, buttonSpan);
    }
    
}

- (void)insertRadioItem:(NSString *)item atIndex:(NSUInteger)index
{
    if (index <= [self.radioArray count]) {
            
        UIControl *container = [[[UIControl alloc] init] autorelease];
        container.clipsToBounds = NO;
        [container addTarget:self action:@selector(radioItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [container addTarget:self action:@selector(radioItemDepressed:) forControlEvents:UIControlEventTouchDown];
        
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.tag = 1;
        label.text = item;
        label.font = self.font;
        [container addSubview:label];
        [self.labelArray addObject:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 2;
        
        [button addTarget:self action:@selector(radioButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(radioButtonDepressed:) forControlEvents:UIControlEventTouchDown];
        [button setImage:self.defaultUnselectedRadioImage forState:UIControlStateNormal];
        [button setImage:self.defaultSelectedRadioImage forState:UIControlStateSelected];
        
        [container addSubview:button];
        [self.buttonArray insertObject:button atIndex:index];
                                        
        [self insertSubview:container atIndex:index];
        [self.radioArray insertObject:container atIndex:index];
        
        // Debug
        if (0) {
            container.layer.borderWidth = 1;
            label.layer.borderWidth = 1;
            button.layer.borderWidth = 1;
        }
        
        [self setNeedsLayout];

    }
}

- (UIImage *)defaultUnselectedRadioImage
{
    if (!defaultUnselectedRadioImage) {
        CGFloat graphicSpan = SCHBSBReplacedElementRadioGraphicSpan;
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
        
        defaultUnselectedRadioImage = UIGraphicsGetImageFromCurrentImageContext();
        [defaultUnselectedRadioImage retain];
        
        UIGraphicsEndImageContext();
    }
    
    return defaultUnselectedRadioImage;
}

- (UIImage *)defaultSelectedRadioImage
{
    if (!defaultSelectedRadioImage) {
        CGFloat graphicSpan = SCHBSBReplacedElementRadioGraphicSpan;
        CGRect graphicRect = CGRectMake(0, 0, graphicSpan, graphicSpan);
        
        UIGraphicsBeginImageContextWithOptions(graphicRect.size, NO, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, graphicRect);
        CGRect elipseBounds = CGRectInset(graphicRect, 1.0f, 1.0f);
        CGRect buttonBounds = CGRectInset(elipseBounds, 7.0f, 7.0f);
        
        CGContextSaveGState(ctx);
        CGContextBeginPath(ctx);
        CGContextAddEllipseInRect(ctx, elipseBounds);
        CGContextClip(ctx);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        
        NSArray *buttonColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.2f].CGColor, nil];
        NSArray *recessColors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.76f].CGColor, (id)[UIColor colorWithWhite:0.1f alpha:0.5f].CGColor, nil];
        
        CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) buttonColors, locations);
        CGGradientRef recessGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) recessColors, locations);
        
        CGPoint startPoint = CGPointMake(CGRectGetMidX(elipseBounds), CGRectGetMinY(elipseBounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(elipseBounds), CGRectGetMaxY(elipseBounds));
        
        CGContextDrawLinearGradient(ctx, recessGradient, startPoint, endPoint, 0);
        
        CGContextSaveGState(ctx);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1.5f), 0, [UIColor colorWithWhite:0 alpha:0.7f].CGColor);
        CGContextBeginTransparencyLayer(ctx, NULL);
        CGContextBeginPath(ctx);
        CGContextAddEllipseInRect(ctx, buttonBounds);
        CGContextClip(ctx);
        
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
        CGContextFillRect(ctx, buttonBounds);
        CGContextDrawLinearGradient(ctx, buttonGradient, startPoint, endPoint, 0);
        CGContextEndTransparencyLayer(ctx);
        CGContextRestoreGState(ctx);
        
        CGGradientRelease(buttonGradient);
        CGGradientRelease(recessGradient);
        CGColorSpaceRelease(colorSpace);
        CGContextRestoreGState(ctx);
        
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.7f);
        CGContextSetLineWidth(ctx, 1.5f);
        CGContextStrokeEllipseInRect(ctx, elipseBounds);
        
        defaultSelectedRadioImage = UIGraphicsGetImageFromCurrentImageContext();
        [defaultSelectedRadioImage retain];
        
        UIGraphicsEndImageContext();
    }
    
    return defaultSelectedRadioImage;
}

- (NSUInteger)numberOfButtons
{
    return [self.buttonArray count];
}

- (NSInteger)selectedButtonIndex
{
    NSInteger ret = SCHBSBReplacedElementRadioControlNoButton;
    
    for (UIButton *button in self.buttonArray) {
        if ([button isSelected]) {
            ret = [self.buttonArray indexOfObject:button];
            break;
        }
    }
    
    return ret;
}

- (void)setSelectedButtonIndex:(NSInteger)selectedButtonIndex
{
    if (selectedButtonIndex < [self.buttonArray count]) {
        for (int i = 0; i < [self.buttonArray count]; i++) {
            UIButton *button = [self.buttonArray objectAtIndex:i];
            
            if (i == selectedButtonIndex) {
                if (![button isSelected]) {
                    [button setSelected:YES];
                }
            } else {
                if ([button isSelected]) {
                    [button setSelected:NO];
                }
            }
        }
    }
}

- (void)setTitle:(NSString *)title forButtonAtIndex:(NSUInteger)index
{
    if (index < [self.labelArray count]) {
        [[self.labelArray objectAtIndex:index] setText:title];
    }
}

- (NSString *)titleForButtonAtIndex:(NSUInteger)index
{
    NSString *ret = nil;
    
    if (index < [self.labelArray count]) {
        ret = [[self.labelArray objectAtIndex:index] text];
    }
    
    return ret;
}

- (void)setEnabled:(BOOL)enabled forButtonAtIndex:(NSUInteger)index
{
    if (index < [self.buttonArray count]) {
        [[self.buttonArray objectAtIndex:index] setEnabled:enabled];
    }
}

- (BOOL)isEnabledForButtonAtIndex:(NSUInteger)index
{
    BOOL ret = NO;
    
    if (index < [self.buttonArray count]) {
        ret = [[self.buttonArray objectAtIndex:index] isEnabled];
    }
    
    return ret;
}

- (BOOL)allowsTapOnLabel
{
    return YES;
}
      
#pragma mark - Button events

- (void)radioButtonSelected:(UIControl *)sender
{
    NSInteger index = [self.buttonArray indexOfObject:sender];
    
    if (index == NSNotFound) {
        index = [self.radioArray indexOfObject:sender];
    }
    
    [self setSelectedButtonIndex:index];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)radioItemSelected:(UIControl *)sender
{
    NSInteger index = [self.radioArray indexOfObject:sender];
    
    [self setSelectedButtonIndex:index];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)radioButtonDepressed:(UIControl *)sender
{
    //NSLog(@"Depressed button!");
    // Noop - could add a blur here
}

- (void)radioItemDepressed:(UIControl *)sender
{
    //NSLog(@"Depressed button!");
    // Noop - could add a blur here
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Class methods

+ (CGRect)containerBoundsWithFont:(UIFont *)font forWidth:(CGFloat)width item:(NSString *)item
{
    CGFloat radioSpan = SCHBSBReplacedElementRadioGraphicSpan;
    CGFloat itemPadding = SCHBSBReplacedElementRadioItemPadding;
    CGFloat gutterPadding = SCHBSBReplacedElementRadioGutterPadding;
    CGFloat rightPadding = SCHBSBReplacedElementRadioRightPadding;
    
    CGSize labelSize = [item sizeWithFont:font forWidth:width - radioSpan - gutterPadding - rightPadding lineBreakMode:UILineBreakModeWordWrap];
    
    return CGRectMake(0, 0, MIN(labelSize.width + radioSpan + gutterPadding + rightPadding, width), MAX(labelSize.height, radioSpan) + 2 * itemPadding);
}

+ (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width items:(NSArray *)items
{
    CGSize totalSize = CGSizeMake(0, 0);
    
    for (NSString *item in items) {
        CGSize itemSize = [SCHBSBReplacedElementRadioControl containerBoundsWithFont:font forWidth:width item:item].size;
        totalSize.height += itemSize.height;
        totalSize.width  = MAX(totalSize.width, itemSize.width);
    }
    
    return totalSize;
}

@end
