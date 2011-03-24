//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAsyncBookCoverImageView.h"

@interface SCHBookShelfTableViewCell : UITableViewCell {
	
	
	
}

@property (readonly, retain) SCHAsyncBookCoverImageView *thumbImageView;
@property (nonatomic, retain) UIView *thumbContainerView;
@property (nonatomic, retain) UIView *thumbTintView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *isbn;


- (void) refreshCell;

@end
