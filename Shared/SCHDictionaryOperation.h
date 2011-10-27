//
//  SCHDictionaryOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 27/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHDictionaryOperation : NSOperation

- (void)setNotCancelledCompletionBlock:(void (^)(void))block;

@end
