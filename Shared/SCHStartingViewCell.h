//
//  SCHStartingViewCell.h
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCHStartingViewCellDelegate <NSObject>
@required
- (void)cellButtonTapped:(NSIndexPath *)indexPath;
@end

@interface SCHStartingViewCell : UITableViewCell {}

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, assign) id<SCHStartingViewCellDelegate> delegate;

- (void)setTitle:(NSString *)title;

@end
