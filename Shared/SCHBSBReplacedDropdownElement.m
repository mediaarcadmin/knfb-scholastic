//
//  SCHBSBReplacedDropdownElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 20/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedDropdownElement.h"
#import "SCHBSBReplacedElementWebView.h"
#import "SCHBSBReplacedElementDropdownControl.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import <libEucalyptus/EucCSSDPI.h>

@interface SCHBSBReplacedDropdownElement() <UIWebViewDelegate>

@property (nonatomic, copy) NSArray *keys;
@property (nonatomic, copy) NSArray *values;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIView *dropdownView;

@end

@implementation SCHBSBReplacedDropdownElement

@synthesize keys;
@synthesize values;
@synthesize binding;
@synthesize value;
@synthesize dropdownView;
@synthesize useWebview;

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [dropdownView release], dropdownView = nil;
    [super dealloc];
}

- (id)initWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)dropdownBinding value:(NSString *)aValue
{
    if (self = [super init]) {
        keys = [keyArray copy];
        values = [valueArray copy];
        binding = [dropdownBinding copy];
        value = [aValue copy];
        useWebview = NO;
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    if (self.useWebview) {
        CGFloat adjustedSize;
        
        CGSize textSize = [@"PLACEHOLDER" sizeWithFont:[UIFont fontWithName:@"Times New Roman" size:EucCSSPixelsMediumFontSize] minFontSize:6 actualFontSize:&adjustedSize forWidth:100 lineBreakMode:UILineBreakModeWordWrap];
        
        return CGSizeMake(100, 10 + textSize.height);
    } else {
        UIFont *intrinsicFont = self.font ? : [UIFont systemFontOfSize:EucCSSPixelsMediumFontSize];
        NSMutableArray *allItems = [[self.values mutableCopy] autorelease];
        [allItems addObject:@"Choose One"];
        return [SCHBSBReplacedElementDropdownControl sizeWithFont:intrinsicFont forWidth:300 items:allItems];
    }
}

- (THCGViewSpiritElement *)newViewSpiritElement
{
    if (self.dropdownView) {
        return [[EucUIViewViewSpiritElement alloc] initWithView:self.dropdownView];
    }
    
    return nil;
}

- (UIView *)dropdownView
{
    if (!dropdownView) {
        if (self.useWebview) {
            CGRect dropdownFrame = CGRectZero;
            dropdownFrame.size = self.intrinsicSize;
            
            SCHBSBReplacedElementWebView *webview = [[SCHBSBReplacedElementWebView alloc] initWithFrame:dropdownFrame];
            webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            webview.jsBridgeTarget = self;
            
            NSString *dataBinding = @"foo";
            
            NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<head><style type='text/css'>* {-webkit-touch-callout: none;-webkit-user-select: none; font-family: 'Times New Roman';}</style></head><body><form><select name='%@' onchange='window.location = \"js-bridge:selectionDidChange:\" + this.options[this.selectedIndex].value'><option value=''>Choose One</option><br />", dataBinding];
            NSUInteger elementCount = MIN([self.keys count], [self.values count]);
            
            for (int i = 0; i < elementCount; i++) {
                BOOL selected = [self.value isEqualToString:[self.values objectAtIndex:i]];
                [htmlString appendFormat:@"<option value='%@'%@>%@</option><br />", [self.values objectAtIndex:i], selected ? @" selected='selected'" : @"", [self.keys objectAtIndex:i]];
            }
            
            [htmlString appendString:@"</select></form></body>"];
            
            [webview loadHTMLString:htmlString baseURL:nil];
            UIGraphicsBeginImageContext(CGSizeMake(1, 1));
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            [[webview layer] renderInContext:ctx];
            UIGraphicsEndImageContext();
            
            dropdownView = webview;
        } else {
            SCHBSBReplacedElementDropdownControl *dropdown = [[SCHBSBReplacedElementDropdownControl alloc] initWithFont:self.font width:self.intrinsicSize.width items:self.values];
            [dropdown addTarget:self action:@selector(dropdownSelectionChanged:) forControlEvents:UIControlEventValueChanged];
            
            if (self.value) {
                NSInteger index = [self.values indexOfObject:self.value];
                [dropdown setSelectedItemIndex:index];
            }
            
            dropdownView = dropdown;
        }
    }
    
    return dropdownView;
}

#pragma mark - Target Methods

- (void)dropdownSelectionChanged:(SCHBSBReplacedElementDropdownControl *)sender
{
    NSString *selection = [sender titleForItemAtIndex:[sender selectedItemIndex]];
    NSLog(@"Dropdown changed: %@", selection);
    [self.delegate binding:self.binding didUpdateValue:selection];
}

- (void)selectionDidChange:(NSString *)selection
{
    NSLog(@"Dropdown changed: %@", selection);
    [self.delegate binding:self.binding didUpdateValue:selection];
}

@end

