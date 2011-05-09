//
//  SCHReadingView.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingView.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHTextFlow.h"
#import "SCHBookPoint.h"
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucMenuItem.h>

@implementation SCHReadingView

@synthesize isbn;
@synthesize delegate;
@synthesize xpsProvider;
@synthesize textFlow;

- (void) dealloc
{
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:isbn];
        [xpsProvider release], xpsProvider = nil;
    }
    
    if (textFlow) {
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:isbn];
        [textFlow release], textFlow = nil;
    }
    
    [isbn release], isbn = nil;
    delegate = nil;
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame isbn:(id)aIsbn
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isbn = [aIsbn retain];
        self.opaque = YES;
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        
        xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn] retain];
        textFlow    = [[[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:self.isbn] retain];
    }
    return self;
}

// Overridden methods

- (void)jumpToPageAtIndex:(NSUInteger)page animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToPage:animated: not being overridden correctly.");
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToProgressPositionInBook:animated: not being overridden correctly.");
}

- (void)jumpToNextZoomBlock
{
    // Do nothing
}

- (void)jumpToPreviousZoomBlock
{
    // Do nothing
}

- (void)didEnterSmartZoomMode
{
    // Do nothing
}

- (void)didExitSmartZoomMode
{
    // Do nothing
}

- (void) setFontPointIndex: (NSUInteger) index
{
    // Do nothing
}

- (NSInteger) maximumFontIndex
{
    // Do nothing
    return 0;
}

-(NSInteger) pageCount
{
    // Do nothing
    return 0;
}

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
    return;
}

- (NSUInteger)pageIndexForBookPoint:(SCHBookPoint *)bookPoint
{
    return bookPoint.layoutPage - 1;
}

- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex
{
    NSString *ret = nil;
    
    NSString* section = [self.textFlow sectionUuidForPageNumber:pageIndex + 1];
    THPair* chapter   = [self.textFlow presentationNameAndSubTitleForSectionUuid:section];
    NSString* pageStr = [self displayPageNumberForPageAtIndex:pageIndex];
    
    if (section && chapter.first) {
        if (pageStr) {
            ret = [NSString stringWithFormat:NSLocalizedString(@"Page %@ \u2013 %@",@"Page label with page number and chapter"), pageStr, chapter.first];
        } else {
            ret = [NSString stringWithFormat:@"%@", chapter.first];
        }
    } else {
        if (pageStr) {
            ret = [NSString stringWithFormat:NSLocalizedString(@"Page %@ of %lu",@"Page label X of Y (page number of page count) in SCHLayoutView"), pageStr, (unsigned long)self.pageCount];
        } else {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
            ret = [book XPSTitle];
        }
    }
    
    return ret;
}

- (NSString *)displayPageNumberForPageAtIndex:(NSUInteger)pageIndex
{
    return [self.textFlow contentsTableViewController:nil displayPageNumberForPageIndex:pageIndex];
}

- (void)goToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    return;
}

#pragma mark - EucSelectorDelegate

- (NSArray *)menuItemsForEucSelector:(EucSelector *)selector 
{
    EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Test Menu", "Test Menu option in popup menu")
                                                               action:nil] autorelease];
    
    NSArray *ret = [NSArray arrayWithObjects:dictionaryItem, nil];
    
    return ret;
}

- (UIColor *)eucSelector:(EucSelector *)selector willBeginEditingHighlightWithRange:(EucSelectorRange *)selectedRange
{
    return nil;
}

- (void)eucSelector:(EucSelector *)selector didEndEditingHighlightWithRange:(EucSelectorRange *)originalRange movedToRange:(EucSelectorRange *)movedToRange;
{
    
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {}

@end
