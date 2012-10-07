//
//  SCHProfileViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHProfileViewCellDelegate.h"

typedef enum {
    kSCHProfileCellLayoutStyle1Up = 0,
    kSCHProfileCellLayoutStyle2Up,
    kSCHProfileCellLayoutStyle3Up
} SCHProfileCellLayoutStyle;

@interface SCHProfileViewCell : UITableViewCell 
{    
}

@property (nonatomic, assign) id<SCHProfileViewCellDelegate> delegate;

- (void)setButtonTitles:(NSArray *)buttonTitles forIndexPaths:(NSArray *)indexPaths forCellStyle:(SCHProfileCellLayoutStyle)style;

@end
