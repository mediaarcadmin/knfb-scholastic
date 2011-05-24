//
//  SCHDictionaryViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHDictionaryViewController : UIViewController <UIWebViewDelegate> {
    
}

@property (nonatomic, retain) NSString *categoryMode;
@property (nonatomic, retain) NSString *word;

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
