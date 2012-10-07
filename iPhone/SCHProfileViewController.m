//
//  SCHProfileViewController.m
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "SCHProfileViewController.h"
#import "SCHSettingsViewController.h"
#import "SCHBookShelfViewController.h"
#import "SCHBookShelfViewController_iPad.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHLibreAccessConstants.h"
#import "SCHProfileItem.h"
#import "SCHAuthenticationManager.h"
#import "SCHThemeManager.h"
#import "SCHBookUpdates.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "SCHSyncManager.h"
#import "LambdaAlert.h"
#import "Reachability.h"
#import "SCHProfileSyncComponent.h"
#import "BITModalSheetController.h"

// Constants
static double const kSCHProfileViewControllerMinimumDistinguishedTapDelay = 0.1;

@interface SCHProfileViewController()  

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, assign) NSInteger simultaneousTapCount;

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, retain) NSArray *pagingViewControllers;

- (void)releaseViewObjects;
- (void)checkForBookUpdates;
- (void)checkForBookshelves;
- (void)showUpdatesBubble:(BOOL)show;
- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr;
- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)pushSettingsControllerAnimated:(BOOL)animated;

@end

@implementation SCHProfileViewController

@synthesize scrollView;
@synthesize parentButton;
@synthesize pageControl;
@synthesize forwardingView;

@synthesize currentIndex;
@synthesize pagingViewControllers;

@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize bookUpdates;
@synthesize updatesBubble;
@synthesize profileSetupDelegate;
@synthesize simultaneousTapCount;
@synthesize appController;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deviceDeregistered:)
                                                     name:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileSyncDidComplete:)
                                                     name:SCHProfileSyncComponentDidCompleteNotification
                                                   object:nil];
    }
    return(self);
}

- (void)releaseViewObjects
{
    [scrollView release], scrollView = nil;
    [parentButton release], parentButton = nil;
    [pageControl release], pageControl = nil;
    [forwardingView release], forwardingView = nil;
    [updatesBubble release], updatesBubble = nil;
    [pagingViewControllers release], pagingViewControllers = nil;
}

- (void)dealloc 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                               object:nil];	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidCompleteNotification
                                                  object:nil];
    
    [self releaseViewObjects];
    
    [fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    [bookUpdates release], bookUpdates = nil;
    profileSetupDelegate = nil;
    appController = nil;
        
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.forwardingView.forwardedView = self.scrollView;
    
    NSMutableArray *anArray = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        UITableViewController *vc = [[[UITableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        vc.tableView.backgroundColor = [UIColor clearColor];
        vc.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        vc.tableView.scrollEnabled = NO;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            vc.tableView.rowHeight = 100;
        } else {
            vc.tableView.rowHeight = 60;
        }
        
        vc.tableView.delegate = self;
        vc.tableView.dataSource = self;
        
        [anArray addObject:vc];
    }
    
    self.pagingViewControllers = anArray;
    
    self.currentIndex = 0;
    [self setupScrollViewForIndex:self.currentIndex];
    
    [self.updatesBubble setAlpha:0];
    [self.updatesBubble setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatesBubbleTapped:)];
    [self.updatesBubble addGestureRecognizer:tap];
    [tap release];
}  

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self checkForBookUpdates];
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
   
    if (self.bookUpdates != nil) {
        self.bookUpdates.managedObjectContext = self.managedObjectContext;
    }    

    self.fetchedResultsController = nil;
    for (UITableViewController *vc in self.pagingViewControllers) {
        [vc.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSInteger ret = 0;
	id <NSFetchedResultsSectionInfo> sectionInfo = nil;
	
    NSUInteger resultsPerRow = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        resultsPerRow = 2;
    } else {
        resultsPerRow = 3;
    }
    
	switch (section) {
		case 0:
			sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
            ret = (numberOfObjects > 0 ? numberOfObjects / resultsPerRow : numberOfObjects);
            if (numberOfObjects % resultsPerRow > 0) {
                ret++;
            }
            
            break;
        default:
            break;
	}
	
	return ret;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    SCHProfileViewCell *cell = (SCHProfileViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSUInteger resultsPerRow = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        resultsPerRow = 2;
    } else {
        resultsPerRow = 3;
    }
    
    NSUInteger resultsThisRow = MIN(resultsPerRow, [[self.fetchedResultsController fetchedObjects] count] - indexPath.row * resultsPerRow);
    
    NSRange resultsRange = NSMakeRange(indexPath.row * resultsPerRow, resultsThisRow);

    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (int i = 0; i < resultsRange.length; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:resultsRange.location + i inSection:0];
        SCHProfileItem *profileItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *title = [profileItem displayName] ? : @"";
        [titles addObject:title];
        [indexPaths addObject:indexPath];
    }
    
    SCHProfileCellLayoutStyle style;
    
    switch (resultsThisRow) {
        case 3:
            style = kSCHProfileCellLayoutStyle3Up;
            break;
        case 2:
            style = kSCHProfileCellLayoutStyle2Up;
            break;
        default:
            style = kSCHProfileCellLayoutStyle1Up;
            break;
    }

    [cell setButtonTitles:titles
            forIndexPaths:indexPaths
             forCellStyle:style];
       
    return cell;
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self showUpdatesBubble:NO];
}


#pragma mark - SCHProfileViewCellDelegate

- (void)profileViewCell:(SCHProfileViewCell *)cell 
didSelectButtonAnimated:(BOOL)animated
              indexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section != 0) {
        return;
    }

    // only trigger if there are no other simultaneous taps 
    if (self.simultaneousTapCount == 0) {    
        self.simultaneousTapCount++;
        SCHProfileViewController *weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kSCHProfileViewControllerMinimumDistinguishedTapDelay * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.simultaneousTapCount = 0;
            
            SCHProfileItem *profileItem = [[weakSelf fetchedResultsController] objectAtIndexPath:indexPath];
            if ([profileItem.ProfilePasswordRequired boolValue] == NO) {
                [weakSelf pushBookshelvesControllerWithProfileItem:profileItem];
            } else if (![profileItem hasPassword]) {
                [weakSelf obtainPasswordThenPushBookshelvesControllerWithProfileItem:profileItem];
            } else {
                [weakSelf queryPasswordBeforePushingBookshelvesControllerWithProfileItem:profileItem];
            }            
        });
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    
    if (self.managedObjectContext == nil) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHProfileItem 
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *screenNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceScreenName 
                                                                               ascending:YES
                                                                                selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *firstNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceFirstName 
                                                                              ascending:YES
                                                                               selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *idSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSCHLibreAccessWebServiceID 
                                                                       ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:screenNameSortDescriptor, firstNameSortDescriptor, idSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchedResultsController_;
}    

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    for (UITableViewController *vc in self.pagingViewControllers) {
        [vc.tableView reloadData];
    }
}


#pragma mark - Profile password

- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    SCHLoginPasswordViewController *passwordController = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHProfilePasswordView" bundle:nil];
    
    [passwordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [passwordController setModalPresentationStyle:UIModalPresentationFormSheet];

    passwordController.cancelBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    
    passwordController.retainLoopSafeActionBlock = ^BOOL(NSString *topFieldString, NSString *bottomFieldString) {
        if ([profileItem validatePasswordWith:bottomFieldString] == NO) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incorrect Password", @"") 
                                                                 message:NSLocalizedString(@"The password you entered is not correct. If you have forgotten your password, you can ask your parent to reset it using Parent Tools.", @"")
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
            return NO;
        } else {
            [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
            [self pushBookshelvesControllerWithProfileItem:profileItem];
            [self dismissModalViewControllerAnimated:YES];
            return YES;
        }	
    };
    
    passwordController.controllerType = kSCHControllerPasswordOnlyView;
    [passwordController.profileLabel setText:[profileItem displayName]];
    
    [self presentModalViewController:passwordController animated:YES];
    [passwordController release];
}

- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    SCHLoginPasswordViewController *passwordController = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHSetProfilePasswordView" bundle:nil];

    [passwordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [passwordController setModalPresentationStyle:UIModalPresentationFormSheet];

    passwordController.retainLoopSafeActionBlock = ^BOOL(NSString *topFieldText, NSString *bottomFieldText) {
        if (bottomFieldText != nil && 
            [topFieldText isEqualToString:bottomFieldText]) {
            if ([topFieldText length] > 0) {
                
                if (![[topFieldText substringToIndex:1] isEqualToString:@" "]) {
                    [profileItem setRawPassword:topFieldText];
                    if ([self.managedObjectContext save:nil] == YES) {
                        [[SCHSyncManager sharedSyncManager] passwordSync];
                    }
                    [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
                    [self pushBookshelvesControllerWithProfileItem:profileItem];
                    [self dismissModalViewControllerAnimated:YES];
                    return YES;
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                         message:NSLocalizedString(@"You cannot use spaces at the beginning of your password.", nil)
                                                                        delegate:nil 
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                               otherButtonTitles:nil]; 
                    [errorAlert show];
                    [errorAlert release];
                    return NO;
                }
            } else {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                     message:NSLocalizedString(@"The password cannot be blank.", nil)
                                                                    delegate:nil 
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                           otherButtonTitles:nil]; 
                [errorAlert show];
                [errorAlert release];
                return NO;
            }
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                 message:NSLocalizedString(@"The passwords do not match.", nil)
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show];
            [errorAlert release];
            return NO;
        }
    };
    
    passwordController.controllerType = kSCHControllerDoublePasswordView;
    [passwordController.profileLabel setText:[profileItem displayName]];
    [self presentModalViewController:passwordController animated:YES];
    [passwordController release];
}

- (NSArray *)profileItems
{
    return [self.fetchedResultsController fetchedObjects];
}

#pragma mark - Push bookshelves controller

- (NSArray *)viewControllersForProfileItem:(SCHProfileItem *)profileItem showWelcome:(BOOL)welcome
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    SCHBookShelfViewController *bookShelfViewController = [[self newBookShelfViewController] autorelease];
    bookShelfViewController.profileItem = profileItem;
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    bookShelfViewController.appController = self.appController;
    bookShelfViewController.showWelcome = welcome;
    
    [viewControllers addObject:bookShelfViewController];

    return viewControllers;
}

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    [self.appController presentBookshelfForProfile:profileItem];
}

- (SCHBookShelfViewController *)newBookShelfViewController
{
    SCHBookShelfViewController *bookshelfViewController = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        bookshelfViewController = [[SCHBookShelfViewController_iPad alloc] initWithNibName:@"SCHBookShelfViewController" bundle:nil];
    } else {
        bookshelfViewController = [[SCHBookShelfViewController alloc] init];
    }
    
    return bookshelfViewController;
}

- (IBAction)settings:(id)sender
{
    // only trigger if there are no other simultaneous taps    
    if (self.simultaneousTapCount == 0) {    
        self.simultaneousTapCount++;
        SCHProfileViewController *weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kSCHProfileViewControllerMinimumDistinguishedTapDelay * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.simultaneousTapCount = 0;
            
            [weakSelf pushSettingsControllerAnimated:YES];
        });
    }            
}

- (void)pushSettingsControllerAnimated:(BOOL)animated
{
    [self.appController presentSettings];
}

#pragma mark - SCHSettingsDelegate

- (void)dismissModalViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;
{
    
    SCHProfileViewController *weakSelf = self;
    
    dispatch_block_t afterDismiss = ^{
        if (completion) {
            completion();
        }
        
        [weakSelf checkForBookshelves];
    };
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:afterDismiss];
    
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
    }
    
    [CATransaction commit];

}

- (void)popToRootViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    if (self.modalViewController) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self dismissModalViewControllerAnimated:NO];
            [self.profileSetupDelegate popToRootViewControllerAnimated:YES withCompletionHandler:completion];
        } else {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profileSetupDelegate popToRootViewControllerAnimated:animated withCompletionHandler:completion];
                });
            }];
            [self dismissModalViewControllerAnimated:animated];
            [CATransaction commit];

        }
    } else {
        [self.profileSetupDelegate popToRootViewControllerAnimated:animated withCompletionHandler:completion];
    }
}

- (void)presentWebParentToolsModallyWithToken:(NSString *)token 
                                        title:(NSString *)title 
                                   modalStyle:(UIModalPresentationStyle)style 
                        shouldHideCloseButton:(BOOL)shouldHide 
{
    
//#if USE_CODEANDTHEORY
//    SCHReadingManagerViewController *aReadingManager = [[[SCHReadingManagerViewController alloc] init] autorelease];
//    aReadingManager.modalPresenterDelegate = self;
//    aReadingManager.pToken = token;
//    self.readingManagerController = aReadingManager;
//
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    
//    if (self.modalViewController) {
//        [self dismissModalViewControllerAnimated:NO];
//    }
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [self.navigationController pushViewController:self.readingManagerController animated:YES];
//     } else {
//        [self presentModalViewController:self.readingManagerController animated:YES];
//    }
//    
//    [CATransaction commit];
//#else
//    
//    SCHParentalToolsWebViewController *aParentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
//    aParentalToolsWebViewController.title = title;
//    aParentalToolsWebViewController.modalPresenterDelegate = self;
//    aParentalToolsWebViewController.pToken = token;
//    aParentalToolsWebViewController.shouldHideCloseButton = shouldHide;
//    self.parentalToolsWebViewController = aParentalToolsWebViewController;
//    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    
//    if (self.modalViewController) {
//        [self dismissModalViewControllerAnimated:NO];
//    }
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//
//        BITModalSheetController *aPopoverController = [[BITModalSheetController alloc] initWithContentViewController:aParentalToolsWebViewController];
//        aPopoverController.contentSize = CGSizeMake(540, 620);
//        aPopoverController.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
//        self.webParentToolsPopoverController = aPopoverController;
//        [aPopoverController release];
//        
//        __block BITModalSheetController *weakPopover = self.webParentToolsPopoverController;
//        __block SCHProfileViewController_Shared *weakSelf = self;
//        
//        [self.webParentToolsPopoverController presentSheetInViewController:self animated:NO completion:^{
//            weakSelf.parentalToolsWebViewController.textView.alpha = 0;
//            
//            CGSize expandedSize;
//            
//            if (UIInterfaceOrientationIsPortrait(weakSelf.interfaceOrientation)) {
//                expandedSize = CGSizeMake(700, 530);
//            } else {
//                expandedSize = CGSizeMake(964, 530);
//            }
//            
//            [weakPopover setContentSize:expandedSize animated:YES completion:^{
//                weakSelf.parentalToolsWebViewController.textView.alpha = 1;
//            }];
//        }];
//        
//    } else {
//        [self presentModalViewController:self.parentalToolsWebViewController animated:YES];        
//    }
//    
//    [CATransaction commit];
    
//#endif
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated withSync:(BOOL)shouldSync showValidation:(BOOL)showValidation
{
//    if (self.modalViewController) {
//        [self dismissModalViewControllerAnimated:NO];
//    }
//    
//    __block SCHProfileViewController_Shared *weakSelf = self;
//    
//    dispatch_block_t completion = ^{
//        [weakSelf setWebParentToolsPopoverController:nil];
//        [weakSelf setParentalToolsWebViewController:nil];
//        
//        if ([[weakSelf.modalNavigationController viewControllers] count] == 0) {
//            // The view has been unloaded due to memory pressure
//            // Just push the settings screen, don't bother with re-adding the validation controller
//            [weakSelf pushSettingsControllerAnimated:NO];
//        } else {
//            if (!showValidation) {
//                NSMutableArray *currentControllers = [[[weakSelf.modalNavigationController viewControllers] mutableCopy] autorelease];
//                if ([currentControllers count] > 0) {
//                    [currentControllers removeLastObject];
//                }
//                [weakSelf.modalNavigationController setViewControllers:currentControllers];
//                [weakSelf presentModalViewController:self.modalNavigationController animated:NO];
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (shouldSync) {
//                [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
//            }
//        });
//    };
//    
//#if USE_CODEANDTHEORY
//    
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        completion();
//    }];
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [self.navigationController popViewControllerAnimated:YES];
//    } else {
//        [self presentModalViewController:self.readingManagerController animated:YES];
//    }
//    
//    [CATransaction commit];
//
//#else
//    if ([self.webParentToolsPopoverController isModalSheetVisible]) {
//        
//        self.parentalToolsWebViewController.textView.alpha = 0;
//        
//        if (animated) {
//            [self.webParentToolsPopoverController setContentSize:CGSizeMake(540, 620) animated:YES completion:^{
//                [CATransaction begin];
//                [CATransaction setDisableActions:YES];
//                [weakSelf.webParentToolsPopoverController dismissSheetAnimated:NO completion:^{
//                    completion();
//                    [CATransaction commit];
//                }];
//            }];
//        } else {
//            [weakSelf.webParentToolsPopoverController dismissSheetAnimated:NO completion:nil];
//            completion();
//        }
//    } else {
//        completion();
//    }
//#endif
}

- (void)popModalWebParentToolsToValidationAnimated:(BOOL)animated
{
    [self dismissModalWebParentToolsAnimated:animated withSync:NO showValidation:YES];
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated
{
    [self dismissModalWebParentToolsAnimated:animated withSync:YES showValidation:NO];
}

- (void)waitingForWebParentToolsToComplete
{
    // Do nothing
}

#pragma mark - Book updates

- (void)checkForBookUpdates
{
    if (!self.bookUpdates) {
        self.bookUpdates = [[[SCHBookUpdates alloc] init] autorelease];
        self.bookUpdates.managedObjectContext = self.managedObjectContext;
    }
    
    BOOL shouldShowUpdates = [self.bookUpdates areBookUpdatesAvailable] && 
                             [[Reachability reachabilityForInternetConnection] isReachable];
    
    [self showUpdatesBubble:shouldShowUpdates];
}

- (void)showUpdatesBubble:(BOOL)show
{
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.updatesBubble.alpha = show ? 1.0 : 0.0;
                     }
                     completion:nil];
}

- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr
{
    [self settings:nil];
}

- (void)deviceDeregistered:(NSNotification *)notification
{
    if (self.modalViewController != nil) {
        [self.modalViewController dismissModalViewControllerAnimated:NO];
    }
    
    [self.profileSetupDelegate popToRootViewControllerAnimated:YES withCompletionHandler:^{
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                              message:NSLocalizedString(@"This device has been deregistered. To read eBooks, please register this device again.", @"") ];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:nil];
        [alert show];
        [alert release];
    }];  
}

- (void)checkForBookshelves
{
    if ([[self.fetchedResultsController fetchedObjects] count] == 0) {
                
        __block SCHProfileViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.profileSetupDelegate waitingForBookshelves];
        });
    }
}

- (void)profileSyncDidComplete:(NSNotification *)notification
{
    self.fetchedResultsController = nil;
    for (UITableViewController *vc in self.pagingViewControllers) {
        [vc.tableView reloadData];
    }
}

- (void)setupScrollViewForIndex:(NSInteger)index
{
   // NSUInteger count = 10;
    NSRange visibleRange = NSMakeRange(index, 3);
    //visibleRange = NSIntersectionRange(visibleRange, NSMakeRange(0, count));
    
    
    self.scrollView.contentSize = CGSizeMake(visibleRange.length * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    
    CGRect leftRect = self.scrollView.bounds;
    CGRect currentRect = self.scrollView.bounds;
    CGRect rightRect = self.scrollView.bounds;
    
    if (visibleRange.length == 3) {
        leftRect.origin.x = 0;
        currentRect.origin.x = self.scrollView.frame.size.width;
        rightRect.origin.x = self.scrollView.frame.size.width * 2;
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width,0);
        
    } else if (visibleRange.location == 0) {
        currentRect.origin.x = 0;
        rightRect.origin.x = self.scrollView.frame.size.width;
        
        self.scrollView.contentOffset = CGPointMake(0,0);
        
    } else {
        leftRect.origin.x = 0;
        currentRect.origin.x = self.scrollView.frame.size.width;
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width,0);
    }
    
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    for (int i = 0; i < visibleRange.length; i++) {
        UIView *view = [[self.pagingViewControllers objectAtIndex:visibleRange.location + i] view];
        
        if (i == 0) {
            view.frame = leftRect;
        } else if (i == 1) {
            view.frame = currentRect;
        } else {
            view.frame = rightRect;
        }
        
        [self.scrollView addSubview:view];
    }
}

@end

