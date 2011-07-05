//
//  SCHBookIdentifier.h
//  Scholastic
//
//  Created by Neil Gall on 30/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNumber+ObjectTypes.h"

@interface SCHBookIdentifier : NSObject {}

@property (nonatomic, readonly) NSString *isbn;
@property (nonatomic, readonly) NSNumber *DRMQualifier;

- (id)initWithISBN:(NSString *)isbn DRMQualifier:(NSNumber *)DRMQualifier;

- (id)initWithEncodedString:(NSString *)string;
- (NSString *)encodeAsString;

@end