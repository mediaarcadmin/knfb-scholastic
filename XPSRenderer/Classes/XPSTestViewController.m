//
//  XPSTestViewController.m
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import "XPSTestViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation XPSTestViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	currentPage = 1;
	
	//	NSString *xpsPath = [[NSBundle mainBundle]pathForResource:@"Cars" ofType:@"xps" inDirectory:@"XPS"];
	NSString *xpsPath = [[NSBundle mainBundle] pathForResource:@"Cook Yourself Thin" ofType:@"xps"];
	NSLog(@"Path is: %@", xpsPath);

	testRenderer = [[XPSTestRenderer alloc] initWithPath:xpsPath];
	NSLog(@"test renderer is: %@", testRenderer);
	
	[self loadImageForCurrentPage];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


- (IBAction) previousPage: (id) sender
{
	NSLog(@"Going to the previous page!");
	if (currentPage > 1) {
		currentPage--;
		[self loadImageForCurrentPage];
	}

}

- (IBAction) nextPage: (id) sender
{
	NSLog(@"Going to the next page!");
	
	if (currentPage < [testRenderer pageCount]) {
		currentPage++;
		[self loadImageForCurrentPage];
	}
}

- (void) loadImageForCurrentPage
{
	id context;
	UIView *oldImageView = [pageView viewWithTag:9999];
	
	if (oldImageView) {
		[oldImageView removeFromSuperview];
	}
	
	CGRect pageCrop = [testRenderer cropForPage:currentPage allowEstimate:YES];
	CGContextRef bitmap = [testRenderer RGBABitmapContextForPage:currentPage fromRect:pageCrop minSize:CGSizeMake(pageCrop.size.width, pageCrop.size.height) getContext:&context];
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* result = [UIImage imageWithCGImage:ref];
	CGImageRelease(ref);
	UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
	imageView.tag = 9999;
	
	NSLog(@"Imageview frame: %@", NSStringFromCGRect(imageView.frame));
	[pageView setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
	[pageView addSubview:imageView];
	[imageView release];
	
	[scrollView setContentSize: CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.height)];
	
	[pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", currentPage, [testRenderer pageCount]]];
	[scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}	

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return pageView;
}
	


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
