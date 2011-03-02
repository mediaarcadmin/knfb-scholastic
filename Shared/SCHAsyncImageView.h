//
//  SCHAsyncImageView.h
//  Scholastic
//
//  Created by Gordon Christie on 10/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHAsyncImageView : UIImageView {

}

@property (nonatomic, retain) NSArray *operations;
@property (nonatomic, retain) NSString *imageOfInterest;

- (void) prepareForReuse;

@end
