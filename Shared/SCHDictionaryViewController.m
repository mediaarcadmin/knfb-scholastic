//
//  SCHDictionaryViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryViewController.h"
#import "SCHDictionaryManager.h"
#import "SCHCustomToolbar.h"

@interface SCHDictionaryViewController ()

- (void)releaseViewObjects;
- (void)loadWord;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)setUserInterfaceFromState;

@end

@implementation SCHDictionaryViewController

@synthesize categoryMode;
@synthesize word;
@synthesize topShadow;
@synthesize topBar;
@synthesize contentView;
@synthesize webView;
@synthesize downloadProgressView;
@synthesize progressBar;
@synthesize topLabel;
@synthesize bottomLabel;
@synthesize activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)releaseViewObjects
{
    [topShadow release], topShadow = nil;
    [topBar release], topBar = nil;
    [topLabel release], topLabel = nil;
    [bottomLabel release], bottomLabel = nil;
    [activityIndicator release], activityIndicator = nil;
    [contentView release], contentView = nil;
    [webView release], webView = nil;
    [downloadProgressView release], downloadProgressView = nil;
    [progressBar release], progressBar = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}


- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.topShadow setImage:[UIImage imageNamed:@"reading-view-top-shadow.png"]];

    if ([[SCHDictionaryManager sharedDictionaryManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        [self.contentView addSubview:self.downloadProgressView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserInterfaceFromState) name:kSCHDictionaryStateChange object:nil];

        [self setUserInterfaceFromState];
        
    } else {
        [self loadWord];
    }    
    
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
        
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 34) {
            barFrame.size.height = 44;
            self.topBar.frame = barFrame;
            
            CGRect contentFrame = self.contentView.frame;
            contentFrame.size.height -= 10;
            contentFrame.origin.y += 10;
            self.contentView.frame = contentFrame;
        }
    } else {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 44) {
            barFrame.size.height = 34;
            self.topBar.frame = barFrame;
            
            CGRect contentFrame = self.contentView.frame;
            contentFrame.size.height += 10;
            contentFrame.origin.y -= 10;
            self.contentView.frame = contentFrame;
        }
    }    
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.contentView.frame);
    self.topShadow.frame = topShadowFrame;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)closeDictionaryView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadWord
{
    NSString *htmlString = [[SCHDictionaryManager sharedDictionaryManager] HTMLForWord:self.word category:self.categoryMode];
    
    NSURL *baseURL = [NSURL URLWithString:[[SCHDictionaryManager sharedDictionaryManager] dictionaryDirectory]];
    
    NSLog(@"HTML: %@", htmlString);
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)setUserInterfaceFromState
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHDictionaryDownloadPercentageUpdate object:nil];

    SCHDictionaryProcessingState state = [[SCHDictionaryManager sharedDictionaryManager] dictionaryProcessingState];
    
    BOOL wifiAvailable = [[SCHDictionaryManager sharedDictionaryManager] wifiAvailable];
    BOOL connectionIdle = [[SCHDictionaryManager sharedDictionaryManager] connectionIdle];
    
    
    if (!wifiAvailable) {
        self.topLabel.text = @"We need a Wifi connection to download the dictionary.";
        self.bottomLabel.text = @"Please connect to a Wifi network.";
        [self.activityIndicator stopAnimating];
        self.progressBar.hidden = YES;
        return;
    } else if (!connectionIdle) {
        self.topLabel.text = @"Books are currently downloading.";
        self.bottomLabel.text = @"You can wait for them to finish, or look up your word later.";
        [self.activityIndicator startAnimating];
        self.progressBar.hidden = YES;
        return;
    }

    switch (state) {
        case SCHDictionaryProcessingStateError:
        {
            self.topLabel.text = @"There was an error downloading the dictionary.";
            self.bottomLabel.text = @"Please try again later.";
            [self.activityIndicator stopAnimating];
            self.progressBar.hidden = YES;
            break;
        }
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
        {
            self.topLabel.text = @"The dictionary is currently downloading from the Internet.";
            self.bottomLabel.text = @"You can wait for it to finish, or look up your word later.";
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            break;
        }
        case SCHDictionaryProcessingStateNeedsDownload:
        {
            self.topLabel.text = @"The dictionary is currently downloading from the Internet.";
            self.bottomLabel.text = @"You can wait for it to finish, or look up your word later.";
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadPercentageUpdate:) name:kSCHDictionaryDownloadPercentageUpdate object:nil];
            break;
        }
        case SCHDictionaryProcessingStateReady:
        {
            [self.downloadProgressView removeFromSuperview];
            [self loadWord];
        }
        default:
            break;
    }
}

- (void)downloadPercentageUpdate:(NSNotification *)note {
    
    if (self.progressBar.hidden) {
        [self.activityIndicator stopAnimating];
        self.progressBar.hidden = NO;
    }

    NSDictionary *userInfo = [note userInfo];
    float percentage = [[userInfo objectForKey:@"currentPercentage"] floatValue];
    
    [self.progressBar setProgress:percentage];
}

@end
