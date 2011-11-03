//
//  SCHDictionaryOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 27/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHDictionaryOperation : NSOperation

@property (nonatomic, assign) dispatch_block_t notCancelledCompletionBlock;

@end
