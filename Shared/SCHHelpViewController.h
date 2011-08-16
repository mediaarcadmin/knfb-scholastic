//
//  SCHHelpViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 16/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHPlayButton;

@interface SCHHelpViewController : UIViewController 
{    
}

@property (nonatomic, retain) IBOutlet UIView *movieContainerView;
@property (nonatomic, retain) IBOutlet SCHPlayButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
          youngerMode:(BOOL)youngerMode;

- (IBAction)closeAction:(id)sender;

@end
