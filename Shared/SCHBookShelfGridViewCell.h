//
//  SCHBookShelfGridViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MRGridViewCell.h"
#import "RateView.h"

@class SCHBookCoverView;
@class SCHBookIdentifier;
@protocol SCHBookShelfGridViewCellDelegate;

@interface SCHBookShelfGridViewCell : MRGridViewCell <RateViewDelegate>
{
}

@property (nonatomic, assign) id <SCHBookShelfGridViewCellDelegate> delegate;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL disabledForInteractions;
@property (nonatomic, assign) BOOL shouldWaitForExistingCachedThumbToLoad;
@property (nonatomic, assign) BOOL showRatings;
@property (nonatomic, assign) NSInteger userRating;

@property (nonatomic, retain) SCHBookCoverView *bookCoverView;

- (void)beginUpdates;
- (void)endUpdates;

@end

@protocol SCHBookShelfGridViewCellDelegate <NSObject>

- (void)gridCell:(SCHBookShelfGridViewCell *)cell userRatingChanged:(NSInteger)newRating;

@end