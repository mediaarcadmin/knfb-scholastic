//
//  SCHBookShelfGridViewDataSource.h
//  Scholastic
//
//  Created by Matt Farrugia on 21/09/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "MRGridViewDataSource.h"
#import "SCHBookShelfGridViewCell.h"

@protocol SCHBookShelfGridViewDataSource <MRGridViewDataSource>

- (void)gridView:(MRGridView*)aGridView configureCell:(SCHBookShelfGridViewCell *)cell forGridIndex:(NSInteger)index;

@end

