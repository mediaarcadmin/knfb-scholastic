//
//  SCHBookRange.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookPoint.h"

@interface SCHBookRange : NSObject {}

@property (nonatomic, retain) SCHBookPoint *startPoint;
@property (nonatomic, retain) SCHBookPoint *endPoint;

@end
