//
//  SCHHotSpotCoordinates
//  Scholastic
//
//  Created by John S. Eddie on 13/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHHotSpotCoordinates : NSObject

@property (nonatomic, assign) CGRect rect;

- (void)calculatePathWithText:(NSString *)text;
- (BOOL)containsPoint:(CGPoint)point;
- (BOOL)intersectsRect:(CGRect)aRect;

@end
