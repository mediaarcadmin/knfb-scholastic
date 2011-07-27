//
//  SCHBookShelfGridViewCell.h
//  Scholastic
//
//  Created by Gordon Christie on 07/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MRGridViewCell.h"

@class SCHBookCoverView;
@class SCHBookIdentifier;

@interface SCHBookShelfGridViewCell : MRGridViewCell 
{
}

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL trashed;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL loading;

@property (nonatomic, retain) SCHBookCoverView *bookCoverView;

- (void)beginUpdates;
- (void)endUpdates;

@end
