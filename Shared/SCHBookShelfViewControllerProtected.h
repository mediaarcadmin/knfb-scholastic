//
//  SCHBookShelfViewControllerProtected.h
//  Scholastic
//
//  Created by John S. Eddie on 31/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

- (void)dismissLoadingView;
- (IBAction)changeToGridView:(UIButton *)sender;
- (IBAction)changeToListView:(UIButton *)sender;


@end
