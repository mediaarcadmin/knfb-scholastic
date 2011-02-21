//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBookInfo.h"
#import "SCHAsyncImageView.h"

@interface SCHBookShelfTableViewCell : UITableViewCell {
	
	
	
}

@property (readonly, retain) SCHAsyncImageView *thumbImageView;
@property (nonatomic, retain) UIView *thumbContainerView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) SCHBookInfo *bookInfo;

@end
