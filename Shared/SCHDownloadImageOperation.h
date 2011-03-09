//
//  SCHDownloadImageOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 15/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookInfo.h"

@interface SCHDownloadImageOperation : NSOperation {
	
}

//@property (nonatomic, retain) NSURL *imagePath;
@property (nonatomic, retain) SCHBookInfo *bookInfo;
@property (nonatomic, retain) NSString *localPath;

@end
