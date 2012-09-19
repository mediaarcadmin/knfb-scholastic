//
//  SCHTourFullScreenImageViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 19/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHTourFullScreenImageViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *mainImageView;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) NSString *imageName;
@property (retain, nonatomic) NSString *imageTitle;

@end
