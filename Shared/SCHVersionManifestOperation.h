//
//  SCHVersionManifestOperation.h
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHVersionManifestOperation : NSOperation <NSXMLParserDelegate>

@property (nonatomic, assign) dispatch_block_t notCancelledCompletionBlock;

@end
