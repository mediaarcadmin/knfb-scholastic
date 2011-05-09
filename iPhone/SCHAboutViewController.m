//
//  SCHAboutViewController.m
//  Scholastic
//
//  Created by Arnold Chien on 5/5/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAboutViewController.h"


@implementation SCHAboutViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"About",@"\"About\" view controller title.");
    // Get the marketing version from Info.plist.
    NSString* version = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; 
    NSString* versionText = [NSString stringWithFormat:@"<p><center style=font-family:arial;font-size:35px;><i>Beta version %@</i></center><center style=font-family:arial;font-size:30px;>&copy; Scholastic Inc.  All rights reserved.</center></p>",version];  
    //NSString* versionText = [NSString stringWithFormat:@"<html><body style=\"margin:20px 30px;\"><center><p style=font-family:arial;font-size:40px;><strong>Blio</strong> | <i>Version %@</i></p><hr></center>",version];
    
    NSString* creditsText = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/credits.html"] encoding:NSUTF8StringEncoding error:NULL];
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    UIWebView* textView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [textView loadHTMLString:[versionText stringByAppendingString:creditsText] baseURL:[NSURL URLWithString:
                                                                                        [NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    
    [textView setScalesPageToFit:YES];
    self.view = textView;
    [textView release];
}

@end