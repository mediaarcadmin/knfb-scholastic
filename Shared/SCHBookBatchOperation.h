//
//  SCHBookBatchOperation.h
//  Scholastic
//
//  Created by Matt Farrugia on 19/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookOperation.h"

@interface SCHBookBatchOperation : SCHBookOperation

@property (nonatomic, copy) NSArray* identifiers;

@end
