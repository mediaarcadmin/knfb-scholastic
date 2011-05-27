//
//  SCHDictionaryViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHDictionaryAccessManager.h"
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

    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] != SCHDictionaryProcessingStateReady) {
        [self.contentView addSubview:self.downloadProgressView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserInterfaceFromState) name:kSCHDictionaryStateChange object:nil];

        [self setUserInterfaceFromState];
        
    } else {
        [self loadWord];
    }    
    
    [self.topBar setTintColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    
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
    NSString *htmlString = [[SCHDictionaryAccessManager sharedAccessManager] HTMLForWord:self.word category:self.categoryMode];
    
    NSString *path = [NSString stringWithFormat:@"%@/Images/", 
                      [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory]];
    
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSLog(@"HTML: %@", htmlString);
    NSLog(@"Path: %@", path);
    NSLog(@"URL: %@", [baseURL filePathURL]);
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)setUserInterfaceFromState
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHDictionaryDownloadPercentageUpdate object:nil];

    SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    
    BOOL wifiAvailable = [[SCHDictionaryDownloadManager sharedDownloadManager] wifiAvailable];
    BOOL connectionIdle = [[SCHDictionaryDownloadManager sharedDownloadManager] connectionIdle];
    
    
    if (!wifiAvailable) {
        self.topLabel.text = @"Wifi Connection Needed";
        self.bottomLabel.text = @"We need a Wifi connection to download the dictionary. Please connect to a Wifi network.";
        [self.activityIndicator stopAnimating];
        self.progressBar.hidden = YES;
        return;
    } else if (!connectionIdle) {
        self.topLabel.text = @"Books Downloading";
        self.bottomLabel.text = @"Books are currently downloading. You can wait for them to finish, or look up your word later.";
        [self.activityIndicator startAnimating];
        self.progressBar.hidden = YES;
        return;
    }

    switch (state) {
        case SCHDictionaryProcessingStateError:
        {
            self.topLabel.text = @"Error";
            self.bottomLabel.text = @"There was an error downloading the dictionary. Please try again later.";
            [self.activityIndicator stopAnimating];
            self.progressBar.hidden = YES;
            break;
        }
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
        {
            self.topLabel.text = @"Processing";
            self.bottomLabel.text = @"The dictionary will be ready shortly. Please wait.";
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            break;
        }
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsManifest:
        {
            self.topLabel.text = @"Downloading";
            self.bottomLabel.text = @"The dictionary is currently downloading from the Internet. You can wait for it to finish, or look up your word later.";
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            break;
        }
        case SCHDictionaryProcessingStateNeedsDownload:
        {
            self.topLabel.text = @"Downloading";
            self.bottomLabel.text = @"The dictionary is currently downloading from the Internet. You can wait for it to finish, or look up your word later.";
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadPercentageUpdate:) name:kSCHDictionaryDownloadPercentageUpdate object:nil];
            break;
        }
        case SCHDictionaryProcessingStateReady:
        {
            [self.downloadProgressView removeFromSuperview];
            [self loadWord];
            break;
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
