//
//  SCHBSBReplacedDropdownElement.m
//  Scholastic
//
//  Created by Matt Farrugia on 20/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedDropdownElement.h"
#import "SCHBSBReplacedElementWebView.h"
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBReplacedDropdownElement()

@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSString *binding;
@property (nonatomic, retain) UIView *dropdownView;

@end

@implementation SCHBSBReplacedDropdownElement

@synthesize keys;
@synthesize values;
@synthesize binding;
@synthesize dropdownView;

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [binding release], binding = nil;
    [dropdownView release], dropdownView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point keys:(NSArray *)keyArray values:(NSArray *)valueArray binding:(NSString *)dropdownBinding
{
    if (self = [super initWithPointSize:point]) {
        keys = [keyArray copy];
        values = [valueArray copy];
        binding = [dropdownBinding copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    return CGSizeMake(80, self.pointSize * 1.8);
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
        CGRect dropdownFrame = CGRectZero;
        dropdownFrame.size = self.intrinsicSize;
        
        SCHBSBReplacedElementWebView *webview = [[SCHBSBReplacedElementWebView alloc] initWithFrame:dropdownFrame];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        NSString *dataBinding = @"foo";

        NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<head><style type='text/css'>* {-webkit-touch-callout: none;-webkit-user-select: none; font-size='%fpx'}</style></head><body><form><select name='%@'", self.pointSize, dataBinding];
        NSUInteger elementCount = MIN([self.keys count], [self.values count]);
        
        for (int i = 0; i < elementCount; i++) {
            [htmlString appendFormat:@"<option value='%@'>%@</option><br />", [self.values objectAtIndex:i], [self.keys objectAtIndex:i]];
        }
        
        [htmlString appendString:@"</select></form></body>"];
        
        [webview synchronouslyLoadHTMLString:htmlString baseURL:nil];
        
        dropdownView = webview;
    }
    
    return dropdownView;
}

@end

