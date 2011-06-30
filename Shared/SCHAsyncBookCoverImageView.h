//
//  SCHAsyncBookCoverImageView.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SCHBookIdentifier;

@interface SCHAsyncBookCoverImageView : UIImageView {}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign) CGSize coverSize;

@end
