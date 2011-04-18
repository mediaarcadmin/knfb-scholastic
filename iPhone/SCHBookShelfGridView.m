//
//  SCHBookShelfGridView.m
//  Scholastic
//
//  Created by Matt Farrugia on 18/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfGridView.h"
#import "SCHBookShelfGridShelvesView.h"

@interface SCHBookShelfGridView()

@property (nonatomic, retain) SCHBookShelfGridShelvesView *bookShelvesView;

@end

@implementation SCHBookShelfGridView

@synthesize bookShelvesView;
@synthesize minimumNumberOfShelves;

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

@end
