//
//  SCHProfileViewCellDelegate.h
//  Scholastic
//
//  Created by John Eddie on 22/12/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHProfileViewCell;

@protocol SCHProfileViewCellDelegate <NSObject>

@optional

- (void)profileViewCell:(SCHProfileViewCell *)cell 
didSelectButtonAnimated:(BOOL)animated
              indexPath:indexPath;

@end
