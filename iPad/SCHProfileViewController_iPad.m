//
//  SCHProfileViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPad.h"
#import "SCHBookshelfViewController_iPad.h"
#import "SCHBookshelfViewController.h"
#import "SCHProfileItem.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHThemeManager.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)showLoginControllerWithAnimation:(BOOL)animated;
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated;
- (void)showBookshelfListWithAnimation:(BOOL)animated;

@end

@implementation SCHProfileViewController_iPad

@synthesize tableView;
@synthesize bookshelfViewController;
@synthesize headerView;
@synthesize containerView;
@synthesize loginPasswordController;
@synthesize profilePasswordController;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [bookshelfViewController release], bookshelfViewController = nil;
    [headerView release], headerView = nil;
    [containerView release], containerView = nil;
    [loginPasswordController release], loginPasswordController = nil;
    [profilePasswordController release], profilePasswordController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];

    self.loginPasswordController.controllerType = kSCHControllerLoginView;
    self.loginPasswordController.actionBlock = ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
        
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginPasswordController username] withPassword:[self.loginPasswordController password]];
        [self.loginPasswordController startShowingProgress];
    };
    
    // block gets set when a row is selected
    self.profilePasswordController.controllerType = kSCHControllerPasswordOnlyView;
    self.profilePasswordController.cancelBlock = ^{
        [self showBookshelfListWithAnimation:YES];
    };
    
    self.tableView.tableHeaderView = self.headerView;
    [self.containerView addSubview:self.tableView];

    
#if !LOCALDEBUG	
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	
	if ([authenticationManager hasUsernameAndPassword] == NO) {
        [self showLoginControllerWithAnimation:YES];
	}
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

  

}  


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidUnload {
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - View Shuffling

- (void)showLoginControllerWithAnimation:(BOOL)animated
{
    [self.loginPasswordController viewWillAppear:animated];
    if (animated) {
        self.loginPasswordController.view.alpha = 0.0f;
    }
    
    [self.loginPasswordController.view setFrame:self.containerView.bounds];
    [self.containerView addSubview:self.loginPasswordController.view];
    
    if (animated) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.loginPasswordController.view.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                         }
         ];
    }
    [self.loginPasswordController viewDidAppear:animated];
}
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated
{
    [self.profilePasswordController viewWillAppear:animated];
    
    if (animated) {
        self.profilePasswordController.view.alpha = 0.0f;
    }
    
    [self.profilePasswordController.view setFrame:self.containerView.bounds];
    [self.containerView addSubview:self.profilePasswordController.view];

    if (animated) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.profilePasswordController.view.alpha = 1.0f;
                         }
                         completion:^(BOOL finished) {
                         }
         ];
    }
    
    [self.profilePasswordController viewDidAppear:animated];

}
- (void)showBookshelfListWithAnimation:(BOOL)animated
{
    [self.loginPasswordController viewWillDisappear:animated];
    [self.profilePasswordController viewWillDisappear:animated];
    if (animated) {
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.loginPasswordController.view.alpha = 0.0f;
                         self.profilePasswordController.view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self.loginPasswordController.view removeFromSuperview];
                         [self.profilePasswordController.view removeFromSuperview];    
                     }
     ];
    } else {
        [self.loginPasswordController.view removeFromSuperview];
        [self.profilePasswordController.view removeFromSuperview];    
    }
    [self.loginPasswordController viewDidDisappear:animated];
    [self.profilePasswordController viewDidDisappear:animated];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    switch (indexPath.section) {
		case 0: {
            
            SCHProfileItem *profileItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
#if LOCALDEBUG
            // controller to view book shelf with books filtered to profile
            [self pushBookshelvesControllerWithProfileItem:profileItem];	
#else
            if ([profileItem.ProfilePasswordRequired boolValue] == NO) {
                [self showBookshelfListWithAnimation:YES];
                [self pushBookshelvesControllerWithProfileItem:profileItem];            
            } else {
                self.profilePasswordController.actionBlock = ^{
                    
                    if ([profileItem validatePasswordWith:[self.profilePasswordController password]] == NO) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                             message:NSLocalizedString(@"Incorrect password", nil)
                                                                            delegate:nil 
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                   otherButtonTitles:nil]; 
                        [errorAlert show]; 
                        [errorAlert release];
                    } else {
                        [self showBookshelfListWithAnimation:YES];
                        [self.profilePasswordController clearFields]; 
                        [self pushBookshelvesControllerWithProfileItem:profileItem];            
                    }	
                };
                
                [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
                
                [self showProfilePasswordControllerWithAnimation:YES];
                
            }
#endif	
		}	break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    if (self.bookshelfViewController) {
        self.bookshelfViewController.profileItem = profileItem;
    }
}

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerFailure object:nil];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
        [self showBookshelfListWithAnimation:YES];
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error!= nil) {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
																 message:[error localizedDescription]
																delegate:nil 
													   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													   otherButtonTitles:nil]; 
			[errorAlert show]; 
			[errorAlert release];
		}	
        [self.loginPasswordController stopShowingProgress];
	}
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

#pragma mark - UIKeyboard Notifications

- (void)keyboardWillShow:(NSNotification *) notification
{
    CGRect keyboardFrame = CGRectNull;
    CGFloat keyboardHeight = 0;
    double keyboardAnimDuration = 0;
    UIViewAnimationCurve keyboardCurve = UIViewAnimationCurveLinear;
    
    // 3.2 and above
    if (UIKeyboardFrameEndUserInfoKey) {		
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimDuration];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardCurve];		
        
        keyboardHeight = fminf(keyboardFrame.size.width, keyboardFrame.size.height);
    }
    
    // centre point for view
    CGFloat centerPoint = ((self.view.frame.size.height - keyboardHeight) / 2);
    
    [UIView beginAnimations:@"moveContainerView" context:nil];
    [UIView setAnimationCurve:keyboardCurve];
    [UIView setAnimationDuration:keyboardAnimDuration];
    
    self.containerView.center = CGPointMake(CGRectGetMidX(self.containerView.frame), centerPoint);
    [UIView commitAnimations];

    
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    
    CGRect keyboardFrame = CGRectNull;
    double keyboardAnimDuration = 0;
    UIViewAnimationCurve keyboardCurve = UIViewAnimationCurveLinear;
    
    // 3.2 and above
    if (UIKeyboardFrameEndUserInfoKey) {		
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimDuration];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardCurve];		
    }
    
    // centre point for view
    CGFloat centerPoint = (self.view.frame.size.height / 2);
    
    [UIView beginAnimations:@"moveContainerView" context:nil];
    [UIView setAnimationCurve:keyboardCurve];
    [UIView setAnimationDuration:keyboardAnimDuration];
    
    self.containerView.center = CGPointMake(CGRectGetMidX(self.containerView.frame), centerPoint);
    [UIView commitAnimations];
}


@end
