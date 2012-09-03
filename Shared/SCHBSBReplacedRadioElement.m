//
//  SCHBSBReplacedRadioElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedRadioElement.h"
#import "SCHBSBReplacedElementWebView.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

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

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [binding release], binding = nil;
    [value release], value = nil;
    [radioView release], radioView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point keys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)radioBinding value:(NSString *)aValue
{
    if (self = [super initWithPointSize:point]) {
        keys = [keyArray copy];
        values = [valueArray copy];
        binding = [radioBinding copy];
        value = [aValue copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    NSUInteger elementCount = MIN([self.keys count], [self.values count]);
    return CGSizeMake(100, 10 + self.pointSize * 2 * elementCount);
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
        CGRect radioFrame = CGRectZero;
        radioFrame.size = self.intrinsicSize;
        
        SCHBSBReplacedElementWebView *webview = [[SCHBSBReplacedElementWebView alloc] initWithFrame:radioFrame];
        webview.jsBridgeTarget = self;
        
        NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<head><style type='text/css'>* {-webkit-touch-callout: none;-webkit-user-select: none; font-size='%fpx'}</style></head><body><form>", self.pointSize];
        NSUInteger elementCount = MIN([self.keys count], [self.values count]);
        NSString *dataBinding = @"foo";
        
        for (int i = 0; i < elementCount; i++) {
            BOOL selected = [self.value isEqualToString:[self.values objectAtIndex:i]];
            [htmlString appendFormat:@"<input type='radio' onchange='window.location = \"js-bridge:selectionDidChange:%@\"' name='%@' value='%@' %@/> %@<br />", [self.values objectAtIndex:i], dataBinding, [self.values objectAtIndex:i], selected ? @" selected='selected'" : @"", [self.keys objectAtIndex:i]];
        }
        
        [htmlString appendString:@"</form></body>"];
        
        [webview loadHTMLString:htmlString baseURL:nil];
        
        radioView = webview;
    }
    
    return radioView;
}

#pragma mark - jsBridgeTarget Methods

- (void)selectionDidChange:(NSString *)selection
{
    NSLog(@"Radio changed: %@", selection);
    [self.delegate binding:self.binding didUpdateValue:selection];
}


@end
