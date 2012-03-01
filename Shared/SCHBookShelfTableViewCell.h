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

@interface SCHBookShelfTableViewCell : UITableViewCell <RateViewDelegate>
{}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL lastCell;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL disabledForInteractions;
@property (nonatomic, assign) BOOL showStarRatings;

- (void)beginUpdates;
- (void)endUpdates;
- (void)refreshCell;

@end