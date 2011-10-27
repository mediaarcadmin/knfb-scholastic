//
//  SCHDictionaryFileDownloadOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDictionaryDownloadManager.h"
#import "QHTTPOperation.h"
#import "SCHDictionaryOperation.h"

@interface SCHDictionaryFileDownloadOperation : SCHDictionaryOperation <QHTTPOperationDelegate>

@property (nonatomic, retain) SCHDictionaryManifestEntry *manifestEntry;
@end
