//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHBookIdentifier;

@interface SCHBookShelfTableViewCell : UITableViewCell {}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL loading;

- (void)beginUpdates;
- (void)endUpdates;
- (void)refreshCell;

@end