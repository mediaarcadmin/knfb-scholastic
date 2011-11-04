//
//  SCHBookStoryInteractionsDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 03/11/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCHBookStoryInteractionsDelegate <NSObject>
@required

// size in page coordinates of the page at the specified index
- (CGSize)sizeOfPageAtIndex:(NSInteger)pageIndex;

@end
