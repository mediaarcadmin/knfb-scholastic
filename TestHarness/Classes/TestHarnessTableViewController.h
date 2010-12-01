
#import <UIKit/UIKit.h>
#import "TestHarnessAppDelegate.h"

@interface TestHarnessTableViewController : UITableViewController {
	NSMutableArray *                resourceTypes;            
	NSMutableArray *                resourcesPerType;         

	NSArray *                       imageFileContentTypes;    
	NSArray *                       docFileContentTypes;      
	NSArray *                       fileContentTypes;      

	NSString *                      defaultCellText;          
	UITableViewCellAccessoryType    disclosureIndicators;     
	UINavigationController *        navigationController;  
	TestHarnessAppDelegate *       appDelegate;
}

@property (nonatomic, retain, readwrite)          NSMutableArray *                resourceTypes;
@property (nonatomic, retain, readwrite)          NSMutableArray *                resourcesPerType;
@property (nonatomic, retain, readwrite)          NSString *                      defaultCellText;
@property (nonatomic, readwrite)                  UITableViewCellAccessoryType    disclosureIndicators;
#ifdef NAVIGATIONCONTROLLER_FROM_NIB
@property (nonatomic, retain) IBOutlet            UINavigationController *        navigationController;
#else
@property (nonatomic, retain)                     UINavigationController *        navigationController;
#endif
/* Until we can set these things dynamically ... */
@property (nonatomic, retain, readwrite)          NSArray *                       imageFileContentTypes;
@property (nonatomic, retain, readwrite)          NSArray *                       docFileContentTypes;
@property (nonatomic, retain, readwrite)          NSArray *                       fileContentTypes;

@property (nonatomic, retain)                     TestHarnessAppDelegate *       appDelegate;

/* Commented out until we can set these things dynamically ... */
#ifdef    DYNAMIC_TABLE_VIEW_CONTENT
- (void)  setTableResourceTypes:        (NSArray *)          types;
- (void)  setTableTargetViewController: (UIViewController *) viewController;
#endif

@end
