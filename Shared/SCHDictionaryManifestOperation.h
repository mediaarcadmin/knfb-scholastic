//
//  SCHDictionaryManifestOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDictionaryOperation.h"

// Constants
extern NSString * const kSCHDictionaryManifestOperationDictionaryText;
extern NSString * const kSCHDictionaryManifestOperationDictionaryPron;
extern NSString * const kSCHDictionaryManifestOperationDictionaryImage;
extern NSString * const kSCHDictionaryManifestOperationDictionaryAudio;

@interface SCHDictionaryManifestOperation : SCHDictionaryOperation <NSXMLParserDelegate> {}

@end
