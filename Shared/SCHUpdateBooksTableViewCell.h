//
//  SCHUpdateBooksTableViewCell.h
//  Scholastic
//
//  Created by Neil Gall on 27/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHUpdateBooksTableViewCellController;
//@class SCHCheckbox;

@interface SCHUpdateBooksTableViewCell : UITableViewCell {}

- (UILabel *)bookTitleLabel;
- (void)enableSpinner:(BOOL)enable;

@end
