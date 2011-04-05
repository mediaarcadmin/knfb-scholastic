//
//  SCHReadingViewController.h
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHReadingViewController : UIViewController {
    
}

@property (nonatomic, assign) BOOL flowView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil book:(id)aBook;

@end
