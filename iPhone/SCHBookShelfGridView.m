//
//  SCHBookShelfGridView.m
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridView.h"
#import "SCHBookShelfGridShelvesView.h"

//static const NSInteger TOGGLE_OFFSET = -64;

@interface SCHBookShelfGridView()

@property (nonatomic, retain) SCHBookShelfGridShelvesView *bookShelvesView;

@end

@implementation SCHBookShelfGridView

@synthesize bookShelvesView;
@synthesize minimumNumberOfShelves;
@synthesize toggleView;

- (void)dealloc
{
    [bookShelvesView release], bookShelvesView = nil;
    [super dealloc];
}

- (void)createBookShelves 
{
	bookShelvesView = [[SCHBookShelfGridShelvesView alloc]initWithFrame:self.bounds];
    bookShelvesView.backgroundColor = [UIColor clearColor];
    bookShelvesView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:bookShelvesView atIndex:0];
    
    NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self createBookShelves];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
	if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
		[self createBookShelves];
	}
    return self;
}

- (void)setToggleView:(UIView *)newToggleView
{
    UIView *oldView = toggleView;
    toggleView = [newToggleView retain];
    [oldView release];
    
    if (toggleView) {
        NSLog(@"Toggle view: %@", self.toggleView);
        self.toggleView.frame = CGRectMake(0, -self.toggleView.frame.size.height, self.frame.size.width, self.toggleView.frame.size.height);
        [self addSubview:self.toggleView];
        self.contentInset = UIEdgeInsetsMake(self.toggleView.frame.size.height, 0, 0, 0);
        NSLog(@"Toggle view after insetting: %@", self.toggleView);
    } else {
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)setShelfImage:(UIImage *)aShelfImage
{
    [self.bookShelvesView setShelfImage:aShelfImage];
}

- (UIImage *)shelfImage
{
    return [self.bookShelvesView shelfImage];
}

- (void)setShelfInset:(CGSize)inset
{
    [self.bookShelvesView setShelfInset:inset];
}

- (CGSize)shelfInset
{
    return [self.bookShelvesView shelfInset];
}

- (void)setShelfHeight:(CGFloat)height
{
    CGFloat currentHeight = [self.bookShelvesView shelfHeight];
    CGRect shelvesFrame = self.bookShelvesView.frame;
    shelvesFrame.size.height -= currentHeight;
    shelvesFrame.size.height += height;
    
    [self.bookShelvesView setFrame:shelvesFrame];
    [self.bookShelvesView setShelfHeight:height];
}

- (CGFloat)shelfHeight
{
    return [self.bookShelvesView shelfHeight];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    CGFloat height = self.shelfHeight;
    CGFloat offset = height * (NSInteger) (scrollView.contentOffset.y / height);
        
    [self.bookShelvesView setTransform:CGAffineTransformMakeTranslation(0, MAX(0, offset))];    
}

- (void)updateSize
{
    [super updateSize];
    self.contentSize = CGSizeMake(self.contentSize.width, MAX(self.contentSize.height, self.shelfHeight * self.minimumNumberOfShelves));
}

- (SCHBookShelfGridViewCell*)dequeueReusableCellWithCellIdentifier:(NSString *)cellIdentifier bookIdentifier:(SCHBookIdentifier *)bookIdentifier {

	SCHBookShelfGridViewCell* gridCell = nil;
	NSMutableArray* reusableCellsForIdentifier = (NSMutableArray*)[reusableCells objectForKey:cellIdentifier];
	if (reusableCellsForIdentifier && [reusableCellsForIdentifier count] > 0)
    {
        // scan through the existing cells to see if one already is set to bookidentifier
        for (SCHBookShelfGridViewCell *tempCell in reusableCellsForIdentifier) {
            if (tempCell.identifier == bookIdentifier) {
                gridCell = tempCell;
                break;
            }
        }
        
        // if not, just grab the first one available
        if (!gridCell) {
            gridCell = [reusableCellsForIdentifier objectAtIndex:0];
        }
        
        // if we have a cell, return that
		if (gridCell) {
			[gridCell retain];
			[reusableCellsForIdentifier removeObjectAtIndex:0];
			[gridCell prepareForReuse];
			[gridCell autorelease];
		}
	}

	return gridCell;
}


//- (void)reloadData
//{
//    NSLog(@"Calling our own reload data method.");
//    //    [super reloadData];
//    
//    [self cleanupAfterCellDrop];
//    
//    // get the currently visible cells
//    NSArray * cellIndexes = [self indexesForCellsInRect:[self bounds]];
//
//    // set them as needing reloading
//    for (NSNumber *index in cellIndexes) {
//        SCHBookShelfGridViewCell *cell = (SCHBookShelfGridViewCell *) [self cellAtGridIndex:[index intValue]];
//        [cell refreshCell];
//    }
//    
////    // collect all the current cells
////	NSMutableArray * keys = [NSMutableArray array];
////	for (id key in cellIndices)
////	{
////		[keys addObject:key];
////	}
////    
////    // remove them all 
////	for (int i = 0; i < [keys count];i++)
////	{
////		NSNumber * numberKey = [keys objectAtIndex:i];
////		[self removeCellAtIndex:[numberKey intValue]];
////		
////	}
////	
////    // remove all the grid view subviews
////    for (UIView * view in [gridView subviews])
////	{
////		[view removeFromSuperview];
////	}
////
////    
////    // add the new cells
////	for (NSNumber* index in cellIndexes){
////    	[self addCellAtIndex:[index intValue]];
////	}
//    
//    // adjust the size of the grid view 
//	//[self updateSize];
//
//}

@end
