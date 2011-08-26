//
//  SCHPictureStarterStickers.m
//  Scholastic
//
//  Created by Neil Gall on 22/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPictureStarterStickers.h"

#define DEBUG_THUMBNAIL_CACHE 1

@interface SCHPictureStarterStickers ()

@property (nonatomic, retain) NSArray *imagePaths;
@property (nonatomic, retain) NSArray *thumbPaths;

+ (void)generateMissingThumbs:(NSArray *)thumbPaths fromImages:(NSArray *)imagePaths;
+ (void)generateThumb:(NSString *)thumbPath fromImage:(NSString *)imagePath;

@end

@implementation SCHPictureStarterStickers

@synthesize imagePaths;
@synthesize thumbPaths;
@synthesize numberOfChoosers;

static dispatch_queue_t thumbQueue = NULL;
static CGContextRef thumbContext = NULL;
static NSFileManager *thumbFileManager = NULL;
static NSMutableDictionary *pendingThumbs = nil;

- (void)dealloc
{
    [imagePaths release], imagePaths = nil;
    [thumbPaths release], thumbPaths = nil;
    [super dealloc];
}

+ (void)initialize
{
    if (self == [SCHPictureStarterStickers class]) {
        thumbFileManager = [[NSFileManager alloc] init];
    }
}

static NSString *cacheDirectory()
{
    NSURL *cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *cachePath = [cacheURL path];
    
#ifdef DEBUG_THUMBNAIL_CACHE
    NSError *error = nil;
    if (![thumbFileManager removeItemAtPath:cachePath error:&error]) {
        NSLog(@"failed to clear thumbnail cache directory %@: %@", cachePath, error);
    }
#endif
    
    return cachePath;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSMutableArray *imagePathsArray = [NSMutableArray array];
        NSMutableArray *thumbPathsArray = [NSMutableArray array];
        
        NSString *root = [[NSBundle mainBundle] pathForResource:@"Stickers" ofType:nil];
        NSString *thumbsRoot = [cacheDirectory() stringByAppendingPathComponent:@"StickerThumbs"];
        NSString *thumbsSuffix = ([[UIScreen mainScreen] scale] == 2 ? @"@2x" : @"");
        
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
            
            BOOL isDirectory;
            if (![fileManager fileExistsAtPath:thumbBinPath isDirectory:&isDirectory] || !isDirectory) {
                if (![fileManager createDirectoryAtPath:thumbBinPath withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"failed to create sticker thumbs directory %@: %@", thumbBinPath, error);
                }
            }

            NSArray *images = [fileManager contentsOfDirectoryAtPath:binPath error:&error];
            if (!images) {
                NSLog(@"failed to find stickers in bin %@: %@", bin, error);
                continue;
            }
            for (NSString *image in images) {
                NSString *imagePath = [binPath stringByAppendingPathComponent:image];
                NSString *thumbFilename = [[[image stringByDeletingPathExtension] stringByAppendingString:thumbsSuffix] stringByAppendingPathExtension:@"png"];
                NSString *thumbPath = [thumbBinPath stringByAppendingPathComponent:thumbFilename];
                [imagePathsArray addObject:imagePath];
                [thumbPathsArray addObject:thumbPath];
            }
        }
        
        self.imagePaths = [NSArray arrayWithArray:imagePathsArray];
        self.thumbPaths = [NSArray arrayWithArray:thumbPathsArray];
        
        NSLog(@"%d stickers found", [self.imagePaths count]);
        
        [SCHPictureStarterStickers generateMissingThumbs:self.thumbPaths fromImages:self.imagePaths];
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

- (NSInteger)arrayIndexForStickerIndex:(NSInteger)sticker inChooser:(NSInteger)chooser
{
    NSInteger countPerChooser = [self.imagePaths count] / self.numberOfChoosers;
    return countPerChooser*chooser + sticker;
}

- (void)thumbnailAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser result:(void (^)(UIImage *))resultBlock
{
    NSInteger thumbIndex = [self arrayIndexForStickerIndex:index inChooser:chooser];
    NSString *thumbPath = [self.thumbPaths objectAtIndex:thumbIndex];
    if ([thumbFileManager fileExistsAtPath:thumbPath]) {
        resultBlock([UIImage imageWithContentsOfFile:thumbPath]);
    } else if (thumbQueue) {
        dispatch_async(thumbQueue, ^{
            if ([thumbFileManager fileExistsAtPath:thumbPath]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock([UIImage imageWithContentsOfFile:thumbPath]);
                });
            } else {
                void (^resultBlockCopy)(UIImage *) = [resultBlock copy];
                [pendingThumbs setValue:resultBlockCopy forKey:thumbPath];
                [resultBlockCopy release];
            }
        });
    }
}

- (UIImage *)imageAtIndex:(NSInteger)index forChooserIndex:(NSInteger)chooser
{
    NSInteger imageIndex = [self arrayIndexForStickerIndex:index inChooser:chooser];
    return [UIImage imageWithContentsOfFile:[self.imagePaths objectAtIndex:imageIndex]];
}

#pragma mark - Thumbnail generation

+ (void)generateMissingThumbs:(NSArray *)thumbPaths fromImages:(NSArray *)imagePaths
{
    if (thumbQueue != NULL) {
        return;
    }
    
    thumbQueue = dispatch_queue_create("stickerThumbs", 0);
    pendingThumbs = [[NSMutableDictionary alloc] init];
    
    for (NSInteger index = 0, count = [imagePaths count]; index < count; ++index) {
        NSString *thumbPath = [thumbPaths objectAtIndex:index];
        if (![thumbFileManager fileExistsAtPath:thumbPath]) {
            NSString *imagePath = [imagePaths objectAtIndex:index];
            dispatch_async(thumbQueue, ^{
                [self generateThumb:thumbPath fromImage:imagePath];
            });
        }
    }
    
    dispatch_async(thumbQueue, ^{
        if (thumbContext) {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_release(thumbQueue), thumbQueue = NULL;
                CGContextRelease(thumbContext), thumbContext = NULL;
                [pendingThumbs release], pendingThumbs = nil;
            });
        }
    });
}

+ (void)generateThumb:(NSString *)thumbPath fromImage:(NSString *)imagePath
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSInteger thumbSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        thumbSize = 60;
    } else {
        thumbSize = 49 * [[UIScreen mainScreen] scale];
    }
    CGRect thumbRect = CGRectMake(0, 0, thumbSize, thumbSize);

    if (!thumbContext) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        thumbContext = CGBitmapContextCreate(NULL, thumbSize, thumbSize, 8, thumbSize*4, colorSpace, kCGImageAlphaPremultipliedLast);
    }
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    if (image) {
        // create the thumbnail
        CGContextClearRect(thumbContext, thumbRect);
        CGContextDrawImage(thumbContext, thumbRect, [image CGImage]);
        [image release];
        CGImageRef thumb = CGBitmapContextCreateImage(thumbContext);
        UIImage *thumbImage = [[UIImage alloc] initWithCGImage:thumb scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        
        NSLog(@"create %@", thumbPath); 

        // dispatch any block waiting on this thumb
        void (^pendingBlock)(UIImage *) = [pendingThumbs objectForKey:thumbPath];
        if (pendingBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                pendingBlock(thumbImage);
            });
            [pendingThumbs removeObjectForKey:thumbPath];
        }
        
        // write to file for future access
        NSData *thumbPNG = UIImagePNGRepresentation(thumbImage);
        [thumbPNG writeToFile:thumbPath atomically:YES];
        [thumbImage release];
        CGImageRelease(thumb);
    }
    
    [pool drain];
}

@end
