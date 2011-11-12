//
//  SCHBookCoverView.h
//  Scholastic
//
//  Created by Gordon Christie on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookIdentifier.h"

typedef enum {
    SCHBookCoverViewModeGridView,
    SCHBookCoverViewModeListView
} SCHBookCoverViewMode;


@interface SCHBookCoverView : UIView {
    
}

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat leftRightInset;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, assign) BOOL isNewBook;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) SCHBookCoverViewMode coverViewMode;

- (void)beginUpdates;
- (void)endUpdates;
- (void)refreshBookCoverView;

- (void)prepareForReuse;

@end
