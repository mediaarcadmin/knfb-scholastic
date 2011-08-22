//
//  SCHPictureStarterStampChooser.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterStickerChooser.h"
#import "SCHPictureStarterStickerChooserDataSource.h"

enum {
    kCellImageViewTag = 101,
    kThumbnailWidth = 49,
    kThumbnailHeight = 49,
    kThumbnailVerticalSpace = 5
};

@implementation SCHPictureStarterStickerChooser

@synthesize chooserIndex;
@synthesize stickerDataSource;

- (void)setStickerDataSource:(id<SCHPictureStarterStickerChooserDataSource>)newStickerDataSource
{
    self.dataSource = self;
    self.rowHeight = kThumbnailHeight + kThumbnailVerticalSpace;
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
    static NSString * const CellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kThumbnailWidth, kThumbnailHeight)];
        cellImageView.center = CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds));
        cellImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
                                          | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        cellImageView.tag = kCellImageViewTag;
        cellImageView.backgroundColor = [UIColor clearColor];
        [cell addSubview:cellImageView];
        [cellImageView release];
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kCellImageViewTag];
    imageView.image = [self.stickerDataSource thumbnailAtIndex:indexPath.row forChooserIndex:self.chooserIndex];
    return cell;
}


@end
