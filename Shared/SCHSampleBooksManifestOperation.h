//
//  SCHSampleBooksManifestOperation.h
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHSampleBooksManager.h"

@interface SCHSampleBooksManifestOperation : NSOperation  <NSXMLParserDelegate> {}

@property (nonatomic, assign) id<SCHSampleBooksProcessingDelegate> processingDelegate;
@property (nonatomic, copy) NSURL *manifestURL;

@end
