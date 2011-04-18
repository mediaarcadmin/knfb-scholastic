//
//  SCHBookShelfGridView.h
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "MRGridView.h"

@interface SCHBookShelfGridView : MRGridView {
    
}

@property (nonatomic, assign) NSUInteger minimumNumberOfShelves;
@property (nonatomic, assign) CGFloat shelfHeight;
@property (nonatomic, assign) CGSize  shelfInset;
@property (nonatomic, retain) UIImage *shelfImage;

@end
