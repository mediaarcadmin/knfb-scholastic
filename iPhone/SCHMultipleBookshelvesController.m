//
//  SCHMultipleBookshelvesController.m
//  Scholastic
//
//  Created by Matt Farrugia on 31/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHMultipleBookshelvesController.h"
#import "SCHBookShelfViewController.h"
#import "SCHLocalDebug.h"
#import "SCHContentProfileItem.h"
#import "SCHContentMetadataItem.h"

@interface SCHMultipleBookshelvesController()

- (void)releaseViewObjects;
- (NSUInteger)numberOfBookshelves;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *books;
@property (nonatomic, assign) BOOL pageControlUsed;
@property (nonatomic, assign) NSUInteger selectedSegment;

@end


@implementation SCHMultipleBookshelvesController

@synthesize books, managedObjectContext, viewControllers, scrollView, pageControl, pageControlUsed, selectedSegment;

- (void)dealloc
{
	[self releaseViewObjects];
	
	[viewControllers release], viewControllers = nil;
	[managedObjectContext release], managedObjectContext = nil;
	[books release], books = nil;
	
    [super dealloc];
}

- (void)releaseViewObjects 
{
	[scrollView release], scrollView = nil;
    [pageControl release], pageControl = nil;
}

- (void)viewDidUnload 
{
	[self releaseViewObjects];
}

- (void)viewDidLoad
{
	// a page is the width of the scroll view
	self.scrollView.pagingEnabled = YES;
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self numberOfBookshelves], self.scrollView.frame.size.height);
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.scrollsToTop = NO;
	self.scrollView.delegate = self;
	
	self.pageControl.numberOfPages = [self numberOfBookshelves];
	self.pageControl.currentPage = 0;
	
	UISegmentedControl *bookshelfToggle = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
	bookshelfToggle.selectedSegmentIndex = 0;
	bookshelfToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	[bookshelfToggle addTarget:self action:@selector(bookshelfToggled:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:bookshelfToggle] autorelease];
	[bookshelfToggle release];
	
	
	// pages are created on demand
	// load the visible page
	// load the page on either side to avoid flashes when the user starts scrolling
	[self loadScrollViewWithPage:0];
	[self loadScrollViewWithPage:1];
	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil managedObjectContext:(NSManagedObjectContext *)moc books:(NSArray *)aBooksArray
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:bundleOrNil])) {
		
		managedObjectContext = [moc retain];
		books = [aBooksArray retain];

		// view controllers are created lazily
		// in the meantime, load the array with placeholders which will be replaced on demand
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < [self numberOfBookshelves]; i++)
		{
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
	}
	return self;
}

- (NSUInteger)numberOfBookshelves 
{
	return 3;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self numberOfBookshelves])
        return;
    
    // replace the placeholder if necessary
    SCHBookShelfViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[SCHBookShelfViewController alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
		controller.bookshelvesController = self;
		[controller bookshelfToggled:self.selectedSegment];
		
		if ([controller respondsToSelector:@selector(viewDidLoad)]) {
			[controller viewDidLoad];
		}
		
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
#ifdef LOCALDEBUG
	controller.managedObjectContext = self.managedObjectContext;
#endif
	//controller.books = [self books];
    // NEW
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"SCHContentMetadataItem" inManagedObjectContext:self.managedObjectContext];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSError *error = nil;				
	NSArray *theBooks = [self.managedObjectContext executeFetchRequest:request error:&error];
	controller.books = theBooks;
	
	// END
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (self.pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlUsed = NO;
}

#pragma mark -
#pragma mark Actions

- (void)bookshelfToggled:(id)sender 
{
	self.selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
	
	for (SCHBookShelfViewController *controller in self.viewControllers) {
		if ((NSNull *)controller != [NSNull null]) {
			[controller bookshelfToggled:self.selectedSegment];
		}
	}
}

- (IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    self.pageControlUsed = YES;
}


@end
