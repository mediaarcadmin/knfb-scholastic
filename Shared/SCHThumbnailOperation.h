//
//  SCHThumbnailOperation.h
//  Scholastic
//
//  Created by Gordon Christie on 11/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHThumbnailOperation : NSOperation {

}

//@property (nonatomic, retain) NSString *thumbPath;
//@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *isbn;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL flip;
@property (nonatomic, assign) BOOL aspect;

@end
