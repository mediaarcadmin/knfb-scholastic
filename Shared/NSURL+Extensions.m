//
//  NSURL+Extensions.m
//  Scholastic
//
//  Created by John Eddie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "NSURL+Extensions.h"

@implementation NSURL (NSURLExtensions) 

- (NSDictionary *)queryParameters
{
	NSMutableDictionary *ret = [NSMutableDictionary dictionary];
	NSArray *param = nil;
	NSString *key = nil;
	NSString *value = nil;
	
    for(NSString *parameter in [[self query] componentsSeparatedByString:@"&"]) {
        param = [parameter componentsSeparatedByString:@"="];
        if([param count] == 2) {
            key = [[param objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            value = [[param objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if ([key length] > 0) {
                [ret setObject:([value length] > 0 ? (id)value : [NSNull null]) forKey:key];
            }
        }
    }
    
    return(ret);
}

@end
