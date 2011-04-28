//
//  UIColor+Extensions.h
//  Scholastic
//
//  Created by John S. Eddie on 27/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (Extensions)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (NSString *)hexString;

@end
