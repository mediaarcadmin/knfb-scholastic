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
#import "SCHAppStateManager.h"
#import "SCHAppDictionaryState.h"

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
@synthesize notFoundView;
@synthesize webView;
@synthesize downloadProgressView;
@synthesize progressBar;
@synthesize bottomLabel;
@synthesize activityIndicator;
@synthesize leftBarButtonItemContainer;
@synthesize audioButton;
@synthesize downloadDictionaryButton;

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
    [bottomLabel release], bottomLabel = nil;
    [activityIndicator release], activityIndicator = nil;
    [contentView release], contentView = nil;
    [webView release], webView = nil;
    [downloadProgressView release], downloadProgressView = nil;
    [progressBar release], progressBar = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [audioButton release], audioButton = nil;
    [notFoundView release], notFoundView = nil;
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [categoryMode release], categoryMode = nil;
    [word release], word = nil;

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

    if (![[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryIsAvailable]) {
        [self.contentView addSubview:self.downloadProgressView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUserInterfaceFromState) name:kSCHDictionaryStateChange object:nil];
        [self setUserInterfaceFromState];
        
    } else {
        [self loadWord];
    }    
    
    [self.topBar setTintColor:[UIColor colorWithWhite:0.7f alpha:1.0f]];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[SCHDictionaryAccessManager sharedAccessManager] stopAllSpeaking];
    [super viewWillDisappear:animated];
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    
    if (UIInterfaceOrientationIsPortrait(orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-bottom-bar.png"]];
        [self.audioButton setImage:[UIImage imageNamed:@"icon-audio-younger-small.png"] forState:UIControlStateNormal];
        
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
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"reading-view-bottom-bar.png"]];
        [self.audioButton setImage:[UIImage imageNamed:@"icon-audio-younger-small-landscape.png"] forState:UIControlStateNormal];

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

- (IBAction)closeDictionaryView:(id)sender 
{
    [[SCHDictionaryAccessManager sharedAccessManager] stopAllSpeaking];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadWord
{
    if (![[SCHDictionaryAccessManager sharedAccessManager] dictionaryContainsWord:self.word forCategory:self.categoryMode]) {
        self.audioButton.hidden = YES;
    }
    
    NSString *htmlString = [[SCHDictionaryAccessManager sharedAccessManager] HTMLForWord:self.word category:self.categoryMode];
    
    if (!htmlString) {
        [self.contentView addSubview:self.notFoundView];
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/Images/", 
                      [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryDirectory]];
    
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
    if (self.categoryMode == kSCHDictionaryYoungReader) {
        [[SCHDictionaryAccessManager sharedAccessManager] speakYoungerWordDefinition:self.word];
    }
}

- (IBAction)playWord
{
    if (self.categoryMode == kSCHDictionaryYoungReader) {
        [[SCHDictionaryAccessManager sharedAccessManager] speakYoungerWordDefinition:self.word];
    } else {
        [[SCHDictionaryAccessManager sharedAccessManager] speakWord:self.word category:self.categoryMode];
    }
}

- (IBAction)downloadDictionary:(id)sender
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    [self closeDictionaryView:nil];
}

- (void)setUserInterfaceFromState
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHDictionaryDownloadPercentageUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHDictionaryProcessingPercentageUpdate object:nil];

    // Because the state change notification calls us check if the dictionary is now available
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryIsAvailable] == YES) {
        [self.downloadProgressView removeFromSuperview];
        self.leftBarButtonItemContainer.hidden = NO;
        [self loadWord];
    } else {
        SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];

        BOOL wifiAvailable = [[SCHDictionaryDownloadManager sharedDownloadManager] wifiAvailable];
        BOOL connectionIdle = [[SCHDictionaryDownloadManager sharedDownloadManager] connectionIdle];

        self.leftBarButtonItemContainer.hidden = YES;

        // check to see if we're in a state that needs wifi to proceed
        // if so, notify the user
        if (!wifiAvailable &&
            (state == SCHDictionaryProcessingStateNeedsDownload ||
             state == SCHDictionaryProcessingStateManifestVersionCheck ||
             state == SCHDictionaryProcessingStateNeedsManifest)
            ) {
            self.bottomLabel.text = NSLocalizedString(@"The dictionary download has paused because you do not have a Wi-Fi connection. Please connect to Wi-Fi to continue the download.", nil);
            [self.activityIndicator stopAnimating];
            self.progressBar.hidden = YES;
            self.downloadDictionaryButton.hidden = YES;
            return;
        } else if (!connectionIdle) {
            self.bottomLabel.text = NSLocalizedString(@"eBooks are currently downloading. You can wait for them to finish, or look up your word later.", nil);
            [self.activityIndicator startAnimating];
            self.progressBar.hidden = YES;
            self.downloadDictionaryButton.hidden = YES;
            return;
        }

        BOOL willDownloadAfterHelpVideo = ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserAccepted);
        BOOL isSampleStore = [[SCHAppStateManager sharedAppStateManager] isSampleStore];

        switch (state) {
            case SCHDictionaryProcessingStateInitialNeedsManifest:
            case SCHDictionaryProcessingStateUserSetup:
            case SCHDictionaryProcessingStateUserDeclined:
            {
                if (isSampleStore) {
                    self.bottomLabel.text = NSLocalizedString(@"You have not yet downloaded the Storia dictionary.", nil);
                } else {
                    __block NSString *freeSpaceString = nil;
                    [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
                        freeSpaceString = [state remainingFileSizeToCompleteDownloadAsString];
                    }];

                    if (self.categoryMode == kSCHDictionaryYoungReader) {
                        self.bottomLabel.text = NSLocalizedString(@"Until the dictionary download is complete, pronunciations, images and audio definitions may not be available. "
                                                                  @"Please wait until the dictionary has fully downloaded and installed and try looking up this word again.", nil);
                        self.downloadDictionaryButton.hidden = YES;
                    } else {
                        self.bottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"The Storia dictionary has not been downloaded. "
                                                                                             @"Please click the download button to download it now.\n\n"
                                                                                             @"Please be advised that the dictionary is %@ and may take some time to download completely. "
                                                                                             @"While the dictionary is downloading, you will be able to see text definitions.", nil), freeSpaceString];
                        self.downloadDictionaryButton.hidden = NO;
                    }
                }

                [self.activityIndicator stopAnimating];
                self.progressBar.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateNotEnoughFreeSpaceError:
            {
                __block NSString *freeSpaceString = nil;
                [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
                    freeSpaceString = [state freeSpaceRequiredToCompleteDownloadAsString];
                }];
                self.bottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"There is not enough free space on the device. "
                                                                                     @"Please clear %@ of space and try again.", nil), freeSpaceString];
                [self.activityIndicator stopAnimating];
                self.progressBar.hidden = YES;
                self.downloadDictionaryButton.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateError:
            case SCHDictionaryProcessingStateUnexpectedConnectivityFailureError:
            case SCHDictionaryProcessingStateManifestError:
            case SCHDictionaryProcessingStateDownload416Error:
            case SCHDictionaryProcessingStateUnableToOpenZipError:
            case SCHDictionaryProcessingStateUnZipFailureError:
            case SCHDictionaryProcessingStateParseError:
            case SCHDictionaryProcessingStateDeletingCategory:
            {
                self.bottomLabel.text = NSLocalizedString(@"There was an error downloading the Storia dictionary. Please try again later.", nil);
                [self.activityIndicator stopAnimating];
                self.progressBar.hidden = YES;
                self.downloadDictionaryButton.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateDeleting:
            {
                self.bottomLabel.text = NSLocalizedString(@"The Storia dictionary is currently being deleted from your device. To download the dictionary again, go to Additional Settings within the Reading Manager Menu and select Download Dictionary.", nil);
                [self.activityIndicator stopAnimating];
                self.progressBar.hidden = YES;
                self.downloadDictionaryButton.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateNeedsUnzip:
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processingPercentageUpdate:) name:kSCHDictionaryProcessingPercentageUpdate object:nil];
                self.bottomLabel.text = NSLocalizedString(@"The Storia dictionary is currently installing. You can wait for it to finish, or look up your word later.", nil);
                [self.activityIndicator stopAnimating];
                self.progressBar.progress = 0.9;
                self.progressBar.hidden = NO;
                self.downloadDictionaryButton.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateNeedsParse:
            {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processingPercentageUpdate:) name:kSCHDictionaryProcessingPercentageUpdate object:nil];
                self.bottomLabel.text = NSLocalizedString(@"The Storia dictionary is currently installing. You can wait for it to finish, or look up your word later.", nil);
                [self.activityIndicator stopAnimating];
                self.progressBar.progress = 0.95;
                self.progressBar.hidden = NO;
                self.downloadDictionaryButton.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateManifestVersionCheck:
            case SCHDictionaryProcessingStateNeedsManifest:
            {
                if (!willDownloadAfterHelpVideo) {
                    if (isSampleStore) {
                        self.bottomLabel.text = NSLocalizedString(@"You have not yet downloaded the Storia dictionary.", nil);
                        self.downloadDictionaryButton.hidden = YES;
                    } else {
                        __block NSString *freeSpaceString = nil;
                        [[SCHDictionaryDownloadManager sharedDownloadManager] withAppDictionaryStatePerform:^(SCHAppDictionaryState *state) {
                            freeSpaceString = [state remainingFileSizeToCompleteDownloadAsString];
                        }];

                        if (self.categoryMode == kSCHDictionaryYoungReader) {
                            self.bottomLabel.text = NSLocalizedString(@"Until the dictionary download is complete, pronunciations, images and audio definitions may not be available. "
                                                                      @"Please wait until the dictionary has fully downloaded and installed and try looking up this word again.", nil);
                            self.downloadDictionaryButton.hidden = YES;
                        } else {
                            self.bottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"The Storia dictionary has not been downloaded. "
                                                                                                 @"Please click the download button to download it now.\n\n"
                                                                                                 @"Please be advised that the dictionary is %@ and may take some time to download completely. "
                                                                                                 @"While the dictionary is downloading, you will be able to see text definitions.", nil), freeSpaceString];
                            self.downloadDictionaryButton.hidden = NO;
                        }
                    }
                } else {
                    self.bottomLabel.text = NSLocalizedString(@"The Storia dictionary is currently downloading from the Internet. You can wait for it to finish, or look up your word later.", nil);
                }

                [self.activityIndicator startAnimating];
                self.progressBar.hidden = YES;
                break;
            }
            case SCHDictionaryProcessingStateNeedsDownload:
            {
                self.bottomLabel.text = NSLocalizedString(@"The Storia dictionary is currently being downloaded. Please wait a few minutes and try looking up this word again.", nil);
                [self.activityIndicator stopAnimating];
                self.progressBar.hidden = NO;
                self.progressBar.progress = [SCHDictionaryDownloadManager sharedDownloadManager].currentDictionaryDownloadPercentage;
                self.downloadDictionaryButton.hidden = YES;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadPercentageUpdate:) name:kSCHDictionaryDownloadPercentageUpdate object:nil];
                break;
            }
            case SCHDictionaryProcessingStateReady:
            {
                [self.downloadProgressView removeFromSuperview];
                self.leftBarButtonItemContainer.hidden = NO;
                [self loadWord];
                break;
            }
        }
    }
}

- (void)downloadPercentageUpdate:(NSNotification *)note {
    
    if (self.progressBar.hidden) {
        [self.activityIndicator stopAnimating];
        self.progressBar.hidden = NO;
    }
    
    NSDictionary *userInfo = [note userInfo];
    float percentage = [[userInfo objectForKey:@"currentPercentage"] floatValue];
    
    [self.progressBar setProgress:percentage * 0.8];
}

- (void)processingPercentageUpdate:(NSNotification *)note {
    
    if (self.progressBar.hidden) {
        [self.activityIndicator stopAnimating];
        self.progressBar.hidden = NO;
    }
    
    NSDictionary *userInfo = [note userInfo];
    float percentage = [[userInfo objectForKey:@"currentPercentage"] floatValue];

    SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    
    switch (state) {
        case SCHDictionaryProcessingStateNeedsUnzip:
            [self.progressBar setProgress:0.8 + (percentage * 0.1)];
            break;
        case SCHDictionaryProcessingStateNeedsParse:
            [self.progressBar setProgress:0.9 + (percentage * 0.1)];
            break;
        default:
            NSLog(@"Warning: receiving dictionary percentage updates when not in a processing state.");
            break;
    } 
}

@end
