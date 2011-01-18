//
//  BITObjectMapperProtocol.h
//  WebAPI
//
//  Created by John S. Eddie on 21/12/2010.
//  Copyright 2010 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BITObjectMapperProtocol

- (NSDictionary *)objectFrom:(id)anObject;
- (void)fromObject:(NSDictionary *)object intoObject:(id *)intoObject;

@end
