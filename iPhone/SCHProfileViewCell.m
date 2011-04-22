//
//  SCHProfileViewCell.m
//  Scholastic
//
//  Created by Gordon Christie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewCell.h"

#import "SCHThemeManager.h"
#import "SCHThemeImageView.h"

@interface SCHProfileViewCell()

@property (nonatomic, retain) UIImageView *cellBGImage;

@end

@implementation SCHProfileViewCell

@synthesize cellBGImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:18];
        self.textLabel.minimumFontSize = 14;
        self.textLabel.numberOfLines = 1;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.shadowColor = [UIColor blackColor];
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        self.textLabel.textAlignment = UITextAlignmentCenter;
        
//        cellBGImage = [[SCHThemeImageView alloc] initWithImage:nil];
//        [self.cellBGImage setTheme:kSCHThemeManagerTableViewCellImage];
        
        UIImage *bgImage = [UIImage imageNamed:@"button-blue"];
        
        cellBGImage = [[[UIImageView alloc] initWithImage:[bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0]] autorelease];
        cellBGImage.tag = 666;
        
        CGRect bgFrame = self.contentView.frame;
        
        bgFrame.origin.x = 15;
        bgFrame.size.width = bgFrame.size.width - 30;
        [cellBGImage setFrame:bgFrame];
        
        [self.contentView insertSubview:cellBGImage atIndex:0];
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	
	CGRect bounds = self.contentView.bounds;
	
	CGRect titleFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    if (self.accessoryView) {
        CGRect accessoryFrame = self.accessoryView.frame;
        accessoryFrame.origin.x -= 15;
        self.accessoryView.frame = accessoryFrame;

        titleFrame = CGRectMake(20, 10, bounds.size.width - 40, bounds.size.height - 20);
    }


    cellBGImage = (UIImageView *) [self.contentView viewWithTag:666];
    
    CGRect bgFrame = self.contentView.frame;
    
    bgFrame.origin.x = 15;
    bgFrame.size.width = bgFrame.size.width - 30;
    [cellBGImage setFrame:bgFrame];
    
    [self.textLabel setFrame:titleFrame];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
