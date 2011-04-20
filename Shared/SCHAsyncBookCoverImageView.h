//
//  SCHAsyncBookCoverImageView.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHAsyncBookCoverImageView : UIImageView {

}

@property (nonatomic, retain) NSString *isbn;
@property (nonatomic) CGSize thumbSize;
@property (nonatomic) CGSize coverSize;

@end
