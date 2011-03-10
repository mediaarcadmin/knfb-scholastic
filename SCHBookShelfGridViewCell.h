//
//  SCHBookShelfGridViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRGridViewCell.h"
#import "SCHAsyncImageView.h"
#import "SCHBookInfo.h"

@interface SCHBookShelfGridViewCell : MRGridViewCell {

	
	
}


@property (nonatomic, retain) SCHBookInfo *bookInfo;

@property (nonatomic, retain) SCHAsyncImageView *asyncImageView;
@property (nonatomic, retain) UIView *thumbTintView;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIProgressView *progressView;

- (void) refreshCell;


@end
