//
//  SCHDownloadBookFile.h
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"

@interface SCHDownloadBookFile : NSOperation {

}

@property (nonatomic, retain) SCHBookInfo *bookInfo;
@property BOOL resume;

@end
