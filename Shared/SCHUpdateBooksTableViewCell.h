//
//  SCHUpdateBooksTableViewCell.h
//  Scholastic
//
//  Created by Neil Gall on 27/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHUpdateBooksTableViewCellController;
@class SCHCheckbox;

@interface SCHUpdateBooksTableViewCell : UITableViewCell {}

@property (nonatomic, copy) void (^onCheckboxUpdate)(BOOL enable);

- (IBAction)checkboxUpdated:(SCHCheckbox *)sender;

- (UILabel *)bookTitleLabel;
- (SCHCheckbox *)enabledForUpdateCheckbox;
- (void)enableSpinner:(BOOL)enable;

@end
