//
//  SCHPictureStarterStickers.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterStickers.h"

@interface SCHPictureStarterStickers ()
@property (nonatomic, retain) NSArray *imagePaths;
@property (nonatomic, retain) NSArray *thumbPaths;
@end

@implementation SCHPictureStarterStickers

@synthesize imagePaths;
@synthesize thumbPaths;
@synthesize numberOfChoosers;

- (void)dealloc
{
    [imagePaths release], imagePaths = nil;
    [thumbPaths release], thumbPaths = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *imagePathsArray = [NSMutableArray array];
        NSMutableArray *thumbPathsArray = [NSMutableArray array];
        
        NSString *root = [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil];
        NSString *thumbsRoot = [root stringByAppendingPathComponent:@"Thumbs"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *bins = [fileManager contentsOfDirectoryAtPath:root error:&error];
        if (!bins) {
            NSLog(@"failed to find sticker bins in %@: %@", root, error);
            return nil;
        }
        for (NSString *bin in bins) {
            if (![[bin substringToIndex:3] isEqualToString:@"BIN"]) {
                continue;
            }
            NSString *binPath = [root stringByAppendingPathComponent:bin];
            NSString *thumbBinPath = [thumbsRoot stringByAppendingPathComponent:bin];
            NSArray *images = [fileManager contentsOfDirectoryAtPath:binPath error:&error];
            if (!images) {
                NSLog(@"failed to find stickers in bin %@: %@", bin, error);
                continue;
            }
            for (NSString *image in images) {
                NSString *imagePath = [binPath stringByAppendingPathComponent:image];
                NSString *thumbPath = [thumbBinPath stringByAppendingPathComponent:[@"thumb_" stringByAppendingString:image]];
                [imagePathsArray addObject:imagePath];
                [thumbPathsArray addObject:thumbPath];
            }
        }
        
        self.imagePaths = [NSArray arrayWithArray:imagePathsArray];
        self.thumbPaths = [NSArray arrayWithArray:thumbPathsArray];
        
        NSLog(@"%d stickers found", [self.imagePaths count]);
    }
    
    return self;
}

- (NSInteger)numberOfStickersForChooserIndex:(NSInteger)chooser
{
    NSInteger count = [self.imagePaths count];
    NSInteger countPerChooser = count / self.numberOfChoosers;
    if (chooser < self.numberOfChoosers-1) {
        return countPerChooser;
    } else {
        return count - (countPerChooser * (self.numberOfChoosers-1));
    }
}

- (UIImage *)thumbnailAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser
{
    NSInteger thumbIndex = index*self.numberOfChoosers + chooser;
    return [UIImage imageWithContentsOfFile:[self.thumbPaths objectAtIndex:thumbIndex]];
}

- (UIImage *)imageAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser
{
    NSInteger imageIndex = index*self.numberOfChoosers + chooser;
    return [UIImage imageWithContentsOfFile:[self.imagePaths objectAtIndex:imageIndex]];
}

@end
