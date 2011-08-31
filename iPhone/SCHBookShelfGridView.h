//
//  SCHBookShelfGridView.h
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "MRGridView.h"
#import "SCHBookShelfGridViewCell.h"

@interface SCHBookShelfGridView : MRGridView {
    
}

@property (nonatomic, assign) NSUInteger minimumNumberOfShelves;
@property (nonatomic, assign) CGFloat shelfHeight;
@property (nonatomic, assign) CGSize  shelfInset;
@property (nonatomic, retain) UIImage *shelfImage;
@property (nonatomic, retain) UIView *toggleView;

- (SCHBookShelfGridViewCell*)dequeueReusableCellWithCellIdentifier:(NSString *)cellIdentifier bookIdentifier:(SCHBookIdentifier *)bookIdentifier;

@end
