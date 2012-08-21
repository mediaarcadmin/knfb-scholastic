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

@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSString *binding;
@property (nonatomic, retain) UIView *radioView;

@end

@implementation SCHBSBReplacedRadioElement

@synthesize keys;
@synthesize values;
@synthesize binding;
@synthesize radioView;

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [binding release], binding = nil;
    [radioView release], radioView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point keys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)radioBinding
{
    if (self = [super initWithPointSize:point]) {
        keys = [keyArray copy];
        values = [valueArray copy];
        binding = [radioBinding copy];
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
        
        NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<head><style type='text/css'>* {-webkit-touch-callout: none;-webkit-user-select: none; font-size='%fpx'}</style></head><body><form>", self.pointSize];
        NSUInteger elementCount = MIN([self.keys count], [self.values count]);
        NSString *dataBinding = @"foo";
        
        for (int i = 0; i < elementCount; i++) {
            [htmlString appendFormat:@"<input type='radio' name='%@' value='%@' /> %@<br />", dataBinding, [self.values objectAtIndex:i], [self.keys objectAtIndex:i]];
        }
        
        [htmlString appendString:@"</form></body>"];
        
        [webview synchronouslyLoadHTMLString:htmlString baseURL:nil];
        
        radioView = webview;
    }
    
    return radioView;
}

@end
