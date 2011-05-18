//
//  SCHBookShelfViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 16/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHBookShelfGridView.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHBookManager.h"

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 254;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape_iPad = 266;

@interface SCHBookShelfViewController_iPad ()

//- (void)showProfileListWithAnimation: (BOOL) animated;
//- (void)hideProfileListWithAnimation: (BOOL) animated;

@end

@implementation SCHBookShelfViewController_iPad

@synthesize profileViewController;

- (void)dealloc
{
    [profileViewController release], profileViewController = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.profileViewController = [[SCHProfileViewController_iPad alloc] initWithNibName:nil bundle:nil];
//    self.profileViewController.managedObjectContext = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
//    self.profileViewController.bookshelfViewController = self;
    
//    self.profileViewController.view.hidden = YES;
//    [self.view addSubview:self.profileViewController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if (!self.books || [self.books count] == 0) {
//        [self showProfileListWithAnimation:animated];
//    }
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];        
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:interfaceOrientation].CGImage];
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightLandscape_iPad];
        [self.gridView setShelfInset:CGSizeMake(0, -2)];
    } else {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightPortrait_iPad];
        [self.gridView setShelfInset:CGSizeMake(0, -2)];
    }
}

//- (void)showProfileListWithAnimation: (BOOL) animated
//{
//    self.profileViewController.view.hidden = NO;
//    if (animated) {
//        [UIView animateWithDuration:0.2
//                         animations:^{
//                             self.profileViewController.view.alpha = 1.0f;
//                         }
//                         completion:^(BOOL finished){
//                         }
//         ];
//    } else {
//        self.profileViewController.view.alpha = 1.0f;
//    }
//}
//
//- (void)hideProfileListWithAnimation: (BOOL) animated
//{
//    if (animated) {
//    [UIView animateWithDuration:0.2
//                     animations:^{
//                         self.profileViewController.view.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished){
//                         self.profileViewController.view.hidden = YES;
//                     }
//     ];
//    } else {
//        self.profileViewController.view.alpha = 0.0f;
//        self.profileViewController.view.hidden = YES;
//    }
//}
//
//- (void) setProfileItem:(SCHProfileItem *)profileItem
//{
//    [super setProfileItem:profileItem];
//    [self hideProfileListWithAnimation:YES];
//}

- (CGSize)cellSize
{
    return CGSizeMake(147,218);
}

- (CGFloat)cellBorderSize
{
    return 36;
}
/*
- (IBAction) back
{
    self.books = nil;
    self.navigationItem.title = @"";
//    [self showProfileListWithAnimation:YES];
}
*/
@end
