//
//  SCHBSBReplacedRadioElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedRadioElement.h"
#import "SCHBSBReplacedElementWebView.h"
#import "SCHBSBReplacedElementRadioControl.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import <libEucalyptus/EucCSSDPI.h>

@interface SCHBSBReplacedRadioElement()

@property (nonatomic, copy) NSArray *keys;
@property (nonatomic, copy) NSArray *values;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, retain) UIView *radioView;

@end

@implementation SCHBSBReplacedRadioElement

@synthesize keys;
@synthesize values;
@synthesize binding;
@synthesize value;
@synthesize radioView;
@synthesize useWebview;

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [radioView release], radioView = nil;
    [super dealloc];
}

- (id)initWithKeys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)radioBinding value:(NSString *)aValue
{
    if (self = [super init]) {
        keys = [keyArray copy];
        values = [valueArray copy];
        binding = [radioBinding copy];
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
    
        NSUInteger elementCount = MIN([self.keys count], [self.values count]);

        return CGSizeMake(100, 10 + textSize.height * elementCount);
    } else {
        UIFont *intrinsicFont = self.font ? : [UIFont systemFontOfSize:EucCSSPixelsMediumFontSize];
        return [SCHBSBReplacedElementRadioControl sizeWithFont:intrinsicFont forWidth:300 items:self.values];
    }
}

- (THCGViewSpiritElement *)newViewSpiritElement
{
    if (self.radioView) {
        return [[EucUIViewViewSpiritElement alloc] initWithView:self.radioView];
    }
    
    return nil;
}

- (UIView *)radioView
{
    if (!radioView) {
        
        if (self.useWebview) {
            
            CGRect radioFrame = CGRectZero;
            radioFrame.size = self.intrinsicSize;
            
            SCHBSBReplacedElementWebView *webview = [[SCHBSBReplacedElementWebView alloc] initWithFrame:radioFrame];
            webview.jsBridgeTarget = self;
            
            NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<head><style type='text/css'>* {-webkit-touch-callout: none;-webkit-user-select: none; font-family: 'Times New Roman';}</style></head><body><form>"];
            NSUInteger elementCount = MIN([self.keys count], [self.values count]);
            NSString *dataBinding = @"foo";
            
            for (int i = 0; i < elementCount; i++) {
                BOOL selected = [self.value isEqualToString:[self.values objectAtIndex:i]];
                [htmlString appendFormat:@"<input type='radio' onchange='window.location = \"js-bridge:selectionDidChange:%@\"' name='%@' value='%@' %@/> %@<br />", [self.values objectAtIndex:i], dataBinding, [self.values objectAtIndex:i], selected ? @" selected='true'" : @"", [self.keys objectAtIndex:i]];
            }
            
            [htmlString appendString:@"</form></body>"];
            
            [webview loadHTMLString:htmlString baseURL:nil];
            
            radioView = webview;
            
        } else {
            SCHBSBReplacedElementRadioControl *radio = [[SCHBSBReplacedElementRadioControl alloc] initWithFont:self.font width:self.intrinsicSize.width items:self.values];
            [radio addTarget:self action:@selector(radioSelectionChanged:) forControlEvents:UIControlEventValueChanged];
            
            if (self.value) {
                NSInteger index = [self.values indexOfObject:self.value];
                [radio setSelectedButtonIndex:index];
            }
            
            radioView = radio;
        }
    }
    
    return radioView;
}

#pragma mark - Target Methods

- (void)radioSelectionChanged:(SCHBSBReplacedElementRadioControl *)sender
{
    NSString *selection = [sender titleForButtonAtIndex:[sender selectedButtonIndex]];
    NSLog(@"Radio changed: %@", selection);
    [self.delegate binding:self.binding didUpdateValue:selection];
}

- (void)selectionDidChange:(NSString *)selection
{
    NSLog(@"Radio changed: %@", selection);
    [self.delegate binding:self.binding didUpdateValue:selection];
}


@end
