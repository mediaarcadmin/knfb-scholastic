//
//  SCHHelpVideoManifestOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHHelpVideoManifest.h"
#import "SCHDictionaryOperation.h"

@interface SCHHelpVideoManifestOperation : SCHDictionaryOperation <NSXMLParserDelegate> {}

@property (nonatomic, retain) SCHHelpVideoManifest *manifestItem;

@end
