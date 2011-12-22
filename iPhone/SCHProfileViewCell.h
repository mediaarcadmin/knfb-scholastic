//
//  SCHProfileViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHProfileViewCellDelegate.h"

@interface SCHProfileViewCell : UITableViewCell 
{    
}

@property (nonatomic, assign) id<SCHProfileViewCellDelegate> delegate;

- (void)setLeftButtonTitle:(NSString *)leftButtonTitle 
             leftIndexPath:(NSIndexPath *)aLeftIndexPath
          rightButtonTitle:(NSString *)rightButtonTitle
            rightIndexPath:(NSIndexPath *)aRightIndexPath;

@end
