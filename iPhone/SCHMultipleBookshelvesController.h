//
//  SCHMultipleBookshelvesController.h
//  Scholastic
//
//  Created by Matt Farrugia on 31/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//
//  Based on Apple's PageControl Sample
//

#import <UIKit/UIKit.h>

#import "SCHProfileViewController.h"
#import "SCHComponentDelegate.h"

@class SCHTopFavoritesComponent;

@interface SCHMultipleBookshelvesController : UIViewController <UIScrollViewDelegate, SCHComponentDelegate> 
{
	SCHTopFavoritesComponent *topFavoritesComponent;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, assign) SCHTopFavoritesComponent *topFavoritesComponent;

- (IBAction)changePage:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil managedObjectContext:(NSManagedObjectContext *)moc books:(NSArray *)books;

@end