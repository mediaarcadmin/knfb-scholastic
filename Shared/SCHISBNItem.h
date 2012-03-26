//
//  SCHISBNItem.h
//  Scholastic
//
//  Created by John Eddie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHISBNItem <NSObject>

@required

- (NSNumber *)DRMQualifier;
- (NSNumber *)ContentIdentifierType;
- (NSString *)ContentIdentifier;

@end
