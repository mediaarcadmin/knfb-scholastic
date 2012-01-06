//
//  SCHLoginHandlerDelegate.h
//  Scholastic
//
//  Created by Matt Farrugia on 05/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

@protocol SCHLoginHandlerDelegate

@required
- (void)startShowingProgress;
- (void)stopShowingProgress;
- (void)clearFields;
- (void)clearBottomField;
- (void)setDisplayIncorrectCredentialsWarning:(BOOL)showWarning;

@end

