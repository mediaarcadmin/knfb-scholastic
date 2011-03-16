//
//  SCHAsyncBookCoverImageView.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBookInfo.h"

@interface SCHAsyncBookCoverImageView : UIImageView {

}

@property (nonatomic, retain) SCHBookInfo *bookInfo;
@property (nonatomic) CGSize coverSize;
//@property (nonatomic, retain) NSString *imageOfInterest;

@end
