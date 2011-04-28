//
//  UIColor+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 27/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "UIColor+Extensions.h"

static NSString * const kUIColorExtensionHexStringPrefix = @"#";

@implementation UIColor (Extensions)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    UIColor *ret = nil;
    
    if (hexString != nil) {
        hexString = [hexString stringByReplacingOccurrencesOfString:kUIColorExtensionHexStringPrefix withString:@""];
        hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSScanner *hexScanner = [NSScanner scannerWithString:hexString];
        NSUInteger argbValue = 0;
        [hexScanner scanHexInt:&argbValue]; 
        
        if ([hexString length] > 6) {
            ret = [UIColor colorWithRed:(float)((argbValue & 0xFF0000) >> 16) / 255.0 
                                  green:(float)((argbValue & 0xFF00) >> 8) / 255.0 
                                   blue:(float)(argbValue & 0xFF) / 255.0 
                                  alpha:(float)((argbValue & 0xFF000000) >> 24) / 255.0];
        } else {
            ret = [UIColor colorWithRed:(float)((argbValue & 0xFF0000) >> 16) / 255.0 
                                  green:(float)((argbValue & 0xFF00) >> 8) / 255.0 
                                   blue:(float)(argbValue & 0xFF) / 255.0 
                                  alpha:1.0];            
        }
    }
    
    return(ret);  
}

- (NSString *)hexString
{
    NSString *ret = nil;
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor)) == kCGColorSpaceModelRGB) {
        const CGFloat *colorComponents = CGColorGetComponents(self.CGColor);  
        ret = [NSString stringWithFormat:@"%@%02X%02X%02X%02X", kUIColorExtensionHexStringPrefix, 
               (unsigned short)(colorComponents[3] * 255.0), 
               (unsigned short)(colorComponents[0] * 255.0), 
               (unsigned short)(colorComponents[1] * 255.0), 
               (unsigned short)(colorComponents[2] * 255.0)];
    }
    
    return(ret);
}

@end
