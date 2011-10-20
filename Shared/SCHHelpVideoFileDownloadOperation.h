//
//  SCHHelpVideoFileDownloadOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHDictionaryDownloadManager.h"
#import "SCHHelpVideoManifest.h"

@interface SCHHelpVideoFileDownloadOperation : NSOperation {
    
}

@property (nonatomic, retain) SCHHelpVideoManifest *videoManifest;
@end