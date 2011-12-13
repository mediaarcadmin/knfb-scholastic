//
//  NSString+URLEncoding.h
//  Scholastic
//
//  Created by Matt Farrugia on 13/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//
//  Taken from http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
//

#import <Foundation/Foundation.h>

@interface NSString(URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end
