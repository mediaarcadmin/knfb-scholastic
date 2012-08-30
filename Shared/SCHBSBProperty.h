//
//  SCHBSBProperty.h
//  Scholastic
//
//  Created by Matt Farrugia on 30/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHBSBProperty : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;

- (void)clear;

@end
