//
//  SCHBookShelfGridView.m
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridView.h"
#import "SCHBookShelfGridShelvesView.h"
#import "SCHBookShelfGridViewDataSource.h"

static const CGFloat kSCHBookShelfGridViewFooterHeight = 60;

@interface SCHBookShelfGridView()

@property (nonatomic, retain) SCHBookShelfGridShelvesView *bookShelvesView;
@property (nonatomic, retain) UILabel *footer;

- (CGFloat)heightForFooter;
- (void)positionFooter;
- (void)createBookShelves;

@end

@implementation SCHBookShelfGridView

@synthesize bookShelvesView;
@synthesize minimumNumberOfShelves;
@synthesize toggleView;
@synthesize footer;

- (void)dealloc
{
    [bookShelvesView release], bookShelvesView = nil;
    [toggleView release], toggleView = nil;
    [footer release], footer = nil;
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
    self.contentSize = CGSizeMake(self.contentSize.width, MAX(self.contentSize.height, self.shelfHeight * self.minimumNumberOfShelves) + [self heightForFooter]);
    [self positionFooter];
}

- (void)reloadData{
	[self cleanupAfterCellDrop];
    
    NSArray * cellIndexes = [self indexesForCellsInRect:[self bounds]];
    NSMutableDictionary *existingCells = [NSMutableDictionary dictionary];
    NSArray *currentCells = [self.cellIndices allValues];
    
	NSMutableArray * keys = [NSMutableArray array];
	for (id key in self.cellIndices)
	{
        if ([cellIndexes containsObject:key]) {
            [existingCells setObject:[self.cellIndices objectForKey:key] forKey:key];
        } else {
            [keys addObject:key];
        }
	}
	for (int i = 0; i < [keys count];i++)
	{
		NSNumber * numberKey = [keys objectAtIndex:i];
		[self removeCellAtIndex:[numberKey intValue]];
		
	}
    
    NSArray *allExistingCells = [existingCells allValues];
	for (UIView *view in currentCells)
	{
        if (![allExistingCells containsObject:view]) {
            [view removeFromSuperview];
        }
	}
	
    NSArray *allExistingCellIndices = [existingCells allKeys];
	for (NSNumber* index in cellIndexes){
        if (![allExistingCellIndices containsObject:index]) {
            [self addCellAtIndex:[index intValue]];
        } else {
            SCHBookShelfGridViewCell *gridCell = [existingCells objectForKey:index];
            if ([index intValue] < [self.gridDataSource numberOfItemsInGridView:self]) {
                [(id<SCHBookShelfGridViewDataSource>)self.gridDataSource gridView:self configureCell:gridCell forGridIndex:[index intValue]];
            } else {
                [self removeCellAtIndex:[index intValue]];
            }
        }
	}
	[self updateSize];
}

- (void)rearrangeCells
{
    if (self.window == nil) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        [CATransaction setDisableActions:YES];
    }
    
    [super rearrangeCells];
    
    if (self.window == nil) {
        [CATransaction commit];
    }
}

#pragma mark - Footer

- (UILabel *)footer 
{
    if (!footer) {
        
        CGFloat fontSize;
        CGFloat inset;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fontSize = 17;
            inset = 40;
        } else {
            fontSize = 13;
            inset = 10;
        }
        
        CGRect footerBounds = CGRectInset(self.bounds, inset, 0);
        footerBounds.origin = CGPointZero;
        footerBounds.size.height = kSCHBookShelfGridViewFooterHeight;
        footer = [[UILabel alloc] initWithFrame:footerBounds];
        footer.backgroundColor = [UIColor clearColor];
        footer.font = [UIFont fontWithName:@"Arial" size:fontSize];
        footer.shadowOffset = CGSizeMake(0, -1);
        footer.textAlignment = UITextAlignmentCenter;
        footer.adjustsFontSizeToFitWidth = YES;
        footer.numberOfLines = 3;
        footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        footer.shadowColor = [UIColor colorWithWhite:0 alpha:0.8f];
        [self setFooterTextIsDark:NO];
        
        [self addSubview:footer];
    }
    
    return footer;
}

- (CGFloat)heightForFooter
{
    if (footer) {
        return CGRectGetHeight(footer.bounds);
    } else {
        return 0;
    }
}

- (void)positionFooter
{
    if (footer) {
        footer.center = CGPointMake(ceilf(CGRectGetWidth(self.bounds)/2.0f), self.contentSize.height - ceilf(kSCHBookShelfGridViewFooterHeight/2.0f));
    }
}

- (void)setFooterText:(NSString *)text
{
    self.footer.text = text;
}

- (void)setFooterTextIsDark:(BOOL)isDark
{
    if (isDark) {
        self.footer.textColor = [UIColor colorWithWhite:1 alpha:0.3f];
    } else {
        self.footer.textColor = [UIColor colorWithWhite:0.9f alpha:0.6f];
    }
}

@end
