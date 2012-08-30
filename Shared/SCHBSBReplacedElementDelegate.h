//
//  SCHBSBReplacedElementDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 30/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

@protocol SCHBSBReplacedElementDelegate <NSObject>

@required
- (void)binding:(NSString *)binding didUpdateValue:(NSString *)value;

@end