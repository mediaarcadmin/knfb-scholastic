//
//  SCHDictionaryFileUnzipOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDictionaryDownloadManager.h"
#import "ZipArchive.h"
#import "SCHDictionaryOperation.h"

@class SCHDictionaryManifestEntry;

@interface SCHDictionaryFileUnzipOperation : SCHDictionaryOperation <ZipArchiveDelegate> {
    
}

@property (nonatomic, retain) SCHDictionaryManifestEntry *manifestEntry;

@end
