//
//  SCHBookPoint.h
//  Scholastic
//
//  Created by Matt Farrugia on 28/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHBookPoint : NSObject {}

@property (nonatomic, assign) NSInteger layoutPage;
@property (nonatomic, assign) uint32_t  blockOffset;
@property (nonatomic, assign) uint32_t  wordOffset;
@property (nonatomic, assign) uint32_t  elementOffset;

- (NSComparisonResult)compare:(SCHBookPoint *)rhs;

@end
