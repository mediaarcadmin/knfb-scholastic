//
//  LambdaAlert.h
//  Scholastic
//
//  Created by Matt Farrugia on 01/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LambdaAlert : NSObject

- (id)initWithTitle: (NSString*) title message: (NSString*) message;
- (void)addButtonWithTitle: (NSString*) title block: (dispatch_block_t) block;
- (void)show;
- (void)setSpinnerHidden:(BOOL)hidden;
- (void)dismissAnimated:(BOOL)animated;

@end
