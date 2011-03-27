//
//  SCHReadingView.h
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHReadingView : UIView {
    
}

@property (nonatomic, retain) id book;

- (id)initWithFrame:(CGRect)frame book:(id)book;

@end
