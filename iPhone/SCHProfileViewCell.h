//
//  SCHProfileViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHProfileViewCell;

@protocol SCHProfileViewCellDelegate <NSObject>

@optional
- (void)profileViewCell:(SCHProfileViewCell *)cell didSelectAnimated:(BOOL)animated;

@end

@interface SCHProfileViewCell : UITableViewCell 
{    
}

@property (nonatomic, retain) UIButton *cellButton;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id<SCHProfileViewCellDelegate> delegate;

@end
