//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHBookIdentifier;
@protocol SCHBookShelfTableViewCellDelegate;

@interface SCHBookShelfTableViewCell : UITableViewCell {}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) id <SCHBookShelfTableViewCellDelegate> delegate;

- (void) refreshCell;

@end


@protocol SCHBookShelfTableViewCellDelegate <NSObject>

@optional
- (void)bookShelfTableViewCellSelectedDeleteForIdentifier:(SCHBookIdentifier *)identifier;

@end
