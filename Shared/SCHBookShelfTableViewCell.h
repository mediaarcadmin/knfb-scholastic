//
//  SCHBookShelfTableViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 17/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@class SCHBookIdentifier;

@protocol SCHBookShelfTableViewCellDelegate;

@interface SCHBookShelfTableViewCell : UITableViewCell <RateViewDelegate>
{}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) id <SCHBookShelfTableViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL disabledForInteractions;
@property (nonatomic, assign) NSInteger userRating;

- (void)beginUpdates;
- (void)endUpdates;
- (void)refreshCell;

@end

@protocol SCHBookShelfTableViewCellDelegate <NSObject>

- (void)bookshelfCell:(SCHBookShelfTableViewCell *)cell userRatingChanged:(NSInteger)newRating;

@end