//
//  SCHDownloadFileOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"

typedef enum {
	kSCHDownloadFileTypeXPSBook = 0,
	kSCHDownloadFileTypeCoverImage
} kSCHDownloadFileType;

@interface SCHDownloadFileOperation : NSOperation {

}

@property (nonatomic, retain) SCHBookInfo *bookInfo;
@property BOOL resume;
@property kSCHDownloadFileType fileType;

@end
