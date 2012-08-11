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
@property (nonatomic, retain) UIView *radioView;

@end

@implementation SCHBSBReplacedRadioElement

@synthesize keys;
@synthesize values;
@synthesize radioView;

- (void)dealloc
{
    [keys release], keys = nil;
    [values release], values = nil;
    [radioView release], radioView = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point keys:(NSArray *)keyArray values:(NSArray *)valueArray
{
    if (self = [super initWithPointSize:point]) {
        keys = [keyArray copy];
        values = [valueArray copy];
    }
    
    return self;
}

- (CGSize)intrinsicSize
{
    return self.radioView.bounds.size;
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
        SCHBSBReplacedElementWebView *webview = [[SCHBSBReplacedElementWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
        
        NSMutableString *htmlString = [NSMutableString stringWithString:@"<body><form>"];
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
