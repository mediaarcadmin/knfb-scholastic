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

@property (nonatomic, retain) NSString *isbn;

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn;
- (void) jumpToPage: (NSInteger) page animated: (BOOL) animated;

@end
