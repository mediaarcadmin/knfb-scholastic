//
//  SCHPictureStarterStampChooser.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterStickerChooser.h"
#import "SCHPictureStarterStickerChooserDataSource.h"
#import "SCHPictureStarterStickerChooserDelegate.h"
#import "SCHPictureStarterStickerChooserThumbnailView.h"

enum {
    kThumbnailTag = 101,
    kThumbnailWidth = 49,
    kThumbnailHeight = 49,
    kThumbnailVerticalSpace = 5
};

@interface SCHPictureStarterStickerChooser ()
@property (nonatomic, assign) NSInteger selectedRowIndex;
@end

@implementation SCHPictureStarterStickerChooser

@synthesize chooserIndex;
@synthesize stickerDataSource;
@synthesize stickerDelegate;
@synthesize selectedRowIndex;

- (void)setStickerDataSource:(id<SCHPictureStarterStickerChooserDataSource>)newStickerDataSource
{
    self.dataSource = self;
    self.delegate = self;
    self.selectedRowIndex = NSNotFound;
    self.rowHeight = kThumbnailHeight + kThumbnailVerticalSpace;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    stickerDataSource = newStickerDataSource;
    [self reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stickerDataSource numberOfStickersForChooserIndex:self.chooserIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    static NSString * const CellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect frame = CGRectInset(cell.bounds, iPad ? 5 : 1, 0);
        SCHPictureStarterStickerChooserThumbnailView *thumbnail = [[SCHPictureStarterStickerChooserThumbnailView alloc] initWithFrame:frame];
        thumbnail.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        thumbnail.contentMode = UIViewContentModeCenter;
        thumbnail.tag = kThumbnailTag;
        thumbnail.backgroundColor = [UIColor clearColor];
        [cell addSubview:thumbnail];
        [thumbnail release];
    }

    NSInteger uniqueTag = indexPath.row*10+self.chooserIndex;

    SCHPictureStarterStickerChooserThumbnailView *thumbnail = (SCHPictureStarterStickerChooserThumbnailView *)[cell viewWithTag:kThumbnailTag];
    thumbnail.stickerTag = uniqueTag;
    thumbnail.image = nil;
    
    [self.stickerDataSource thumbnailAtIndex:indexPath.row
                             forChooserIndex:self.chooserIndex
                                      result:^(UIImage *thumb) {
                                          if (thumbnail.stickerTag == uniqueTag) { // guard aginst view reuse
                                              thumbnail.image = thumb;
                                          }
                                      }];
    thumbnail.selected = (self.selectedRowIndex == indexPath.row);
    return cell;
}

- (SCHPictureStarterStickerChooserThumbnailView *)thumbnailAtIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    return (SCHPictureStarterStickerChooserThumbnailView *)[cell viewWithTag:kThumbnailTag];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectRowAtIndexPath:indexPath animated:NO];
    self.selectedRowIndex = indexPath.row;
    [self.stickerDelegate stickerChooser:self.chooserIndex choseImageAtIndex:self.selectedRowIndex];
}

#pragma mark - Selection

- (void)clearSelection
{
    self.selectedRowIndex = NSNotFound;
}

- (void)setSelectedRowIndex:(NSInteger)index
{
    if (selectedRowIndex != NSNotFound) {
        [self thumbnailAtIndex:selectedRowIndex].selected = NO;
    }
    [self thumbnailAtIndex:index].selected = YES;
    selectedRowIndex = index;
}


@end
