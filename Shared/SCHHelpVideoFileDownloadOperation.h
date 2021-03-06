//
//  SCHHelpVideoFileDownloadOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHHelpVideoManifest.h"
#import "QHTTPOperation.h"
#import "SCHDictionaryOperation.h"

@interface SCHHelpVideoFileDownloadOperation : SCHDictionaryOperation <QHTTPOperationDelegate>

@property (nonatomic, retain) SCHHelpVideoManifest *videoManifest;
@end