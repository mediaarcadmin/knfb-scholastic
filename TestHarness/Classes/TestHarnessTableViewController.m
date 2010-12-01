
#import "TestHarnessTableViewController.h"
#import "TestHarnessAppDelegate.h"
#import "TestHarnessViewController.h"

#define			DEBUG 1
#define         kNumResourcesPerType  12

@implementation TestHarnessTableViewController

@synthesize resourceTypes;
@synthesize resourcesPerType;

/* Until we can set these things dynamically ... */
@synthesize imageFileContentTypes;
@synthesize docFileContentTypes;
@synthesize fileContentTypes;
@synthesize defaultCellText;
@synthesize disclosureIndicators;
@synthesize navigationController;
@synthesize appDelegate;

- (void) loadResourceTypes: (NSArray*) resourceTypesToFind
{
	NSArray *  outputArray;
//	NSString * partialDocPath   = [[NSBundle mainBundle] resourcePath];
	NSUInteger typeIndex = 0;

//	- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error

	if (resourceTypesToFind != nil)
	{
		/*
			Given a partial path and a type - (which can be nil), return
			an array with all possible completions.  (Wow, impressive.)
		*/
		for (typeIndex = 0; typeIndex < [resourceTypesToFind count]; typeIndex ++)
		{
			/* Skip nil */
			if ([resourceTypesToFind objectAtIndex: typeIndex] == nil)
				continue;

			/* Skip if already loaded - this allows for multiple resource views to claim a type */
			if ([resourceTypes containsObject:[resourceTypesToFind objectAtIndex: typeIndex]])
				continue;

			outputArray = [[NSBundle mainBundle] pathsForResourcesOfType:[resourceTypesToFind objectAtIndex: typeIndex] inDirectory: nil /* partialDocPath */];
			if (outputArray != nil && [outputArray count] > 0 && [outputArray objectAtIndex:0] != nil)
			{
				[self.resourceTypes addObject: [resourceTypesToFind objectAtIndex: typeIndex]];
				[self.resourcesPerType addObject: outputArray];
			}
		}
	}
}

/*
	The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {

#ifndef NAVIGATIONCONTROLLER_FROM_NIB
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self];
		[self.view addSubview: [self.navigationController view]];
#endif

    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];

	if (self.navigationController == nil)
	{
		self.navigationController = [[UINavigationController alloc] initWithRootViewController:self];
		[self.view addSubview: [self.navigationController view]];
	}

    self.tableView.delegate = self;
    self.tableView.allowsSelection = YES;

	self.disclosureIndicators = UITableViewCellAccessoryDisclosureIndicator;

	self.fileContentTypes   = [NSArray arrayWithObjects:
	                             @"pdf", @"xps", nil];


	self.resourceTypes = [[NSMutableArray alloc] initWithCapacity:[self.fileContentTypes count]];
	self.resourcesPerType = [[NSMutableArray alloc] initWithCapacity:kNumResourcesPerType];
	[self loadResourceTypes: self.fileContentTypes];

	self.appDelegate = (TestHarnessAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)dealloc
{
	[navigationController release];
	[resourceTypes release];
	[resourcesPerType release];
	[fileContentTypes release];
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/* Access the array used to store the resources for the type indexed by "section" */
	NSUInteger count = [[self.resourcesPerType objectAtIndex:section] count];

    /* If there are no resources of this type - just let there be a cell for a default string */
	if (count == 0 && self.defaultCellText)
		return 1;

	return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString * tableCellIdentifier = @"DocumentsViewCell";
	NSUInteger        count               = 0;
	UITableViewCell * cell;
	NSArray *         resourcesByType;
	NSString *        cellString      = [NSString stringWithString:@""];
	NSString *        resourcePath;

	resourcesByType = [self.resourcesPerType objectAtIndex:[indexPath section]];
	if (resourcesByType != nil)
		count = [resourcesByType count];

	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:tableCellIdentifier] autorelease];
		if (cell != nil)
		{
			/*
				Set up some defaults for cell appearance
			*/
			cell.textLabel.textColor = [UIColor blackColor];
			cell.textLabel.font = [UIFont systemFontOfSize:12.0];
			cell.textLabel.adjustsFontSizeToFitWidth = YES;
			cell.textLabel.minimumFontSize           = 9;

		//	default value is 1
		//	cell.textLabel.numberOfLines             = 1;
			
			cell.accessoryType  = self.disclosureIndicators;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
	}

	if (resourcesByType != nil && count > 0)
	{
		resourcePath = [resourcesByType objectAtIndex:indexPath.row];
		if (resourcePath != nil)
		{
			/*
				We only want to display the file/doc name, not the entire path:
					cellString = resourcePath;
			*/		
			cellString = [resourcePath lastPathComponent];
		}
		if (cellString != nil)
		{
			cell.textLabel.text = cellString;
		}
		else
		{
			cell.textLabel.text = [NSString stringWithString:@"Unknown resource"];
			cell.accessoryType  = UITableViewCellAccessoryNone;
		}
	}
	else
	{
        	/*
		    If there are no resources and the default cell text is set,
		    show the user a cell/row with that text and no disclosure indicator.
		*/
		if (self.defaultCellText)
			cell.textLabel.text = self.defaultCellText;
		else
			cell.textLabel.text = @"searching...";

		cell.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		cell.accessoryType       = UITableViewCellAccessoryNone;
	}
	

	return cell;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
	return [self.resourceTypes count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *          resourcesByType      = nil;
	NSString *         resourcePath         = nil;
	NSString *         contentType          = nil;

	/* Supposed to do this ... */
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	resourcesByType = [self.resourcesPerType objectAtIndex:[indexPath section]];
	if (resourcesByType != nil)
		resourcePath = [resourcesByType objectAtIndex:indexPath.row];
	if (resourcePath != nil)
		contentType  = [resourcePath pathExtension];

	if (contentType != nil)
	{
        TestHarnessViewController *testVC = [[[TestHarnessViewController alloc] init] autorelease];
        [testVC setResourcePath:resourcePath];
        [self.navigationController pushViewController:testVC animated:YES];
	}
}


@end
