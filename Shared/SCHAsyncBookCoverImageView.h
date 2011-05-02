//
//  SCHAsyncBookCoverImageView.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHAsyncBookCoverImageView : UIImageView 
{
}

@property (nonatomic, copy) NSString *isbn;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign) CGSize coverSize;

@end
