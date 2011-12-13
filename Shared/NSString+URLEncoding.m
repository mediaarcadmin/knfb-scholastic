//
//  NSString+URLEncoding.m
//  Scholastic
//
//  Created by Matt Farrugia on 13/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString(URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	NSString *encodedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding));
    
    return [encodedURL autorelease];
}

@end