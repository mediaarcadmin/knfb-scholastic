//
//  NSString+EmailValidation.m
//  Scholastic
//
//  Created by John Eddie on 31/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSString+EmailValidation.h"

@implementation NSString (EmailValidation)

// http://cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html

- (BOOL)isValidEmailAddress
{
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegEx];
    
    return [regExPredicate evaluateWithObject:self];    
}

@end
