//
//  SCHBackupPerformedDetector.m
//  Scholastic
//
//  Created by John Eddie on 23/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBackupPerformedDetector.h"

#import "NSFileManager+DoNotBackupExtendedAttribute.h"
#import "SCHAppStateManager.h"

static NSString const * kSCHBackupPerformedDetectorFileName = @"SCHBackupPerformedDetector.txt";

@interface SCHBackupPerformedDetector ()

- (NSString *)filePath;

@end

@implementation SCHBackupPerformedDetector

- (void)createDetectorIfRequired
{    
    if ([self detectorShouldExist] == NO && [self detectorExists] == NO) {
        NSString *filePath = [self filePath];
        if (filePath != nil) {
            NSString *fileContents = @"Do not remove this file used by SCHBackupPerformedDetector";
            NSError *error = nil;
            if ([fileContents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error] == YES) {
                if ([NSFileManager BITsetSkipBackupAttributeToItemAtFilePath:filePath] == NO) {
                    NSLog(@"FAILED: %@ did not set Do Not Backup Extended Attribute.", kSCHBackupPerformedDetectorFileName);                
                }  else {
                    [[SCHAppStateManager sharedAppStateManager] setBackupPerformedDetectorExists:YES];
                }
            }
        }
    }
}

- (void)resetDetectorIfRequired
{
    if ([self detectorExists] == NO) {
        [[SCHAppStateManager sharedAppStateManager] setBackupPerformedDetectorExists:NO];
        [self createDetectorIfRequired];
    }
}

- (BOOL)detectorShouldExist
{
    return [[SCHAppStateManager sharedAppStateManager] backupPerformedDetectorExists];
}

- (BOOL)detectorExists
{
    BOOL ret = NO;
    NSString *filePath = [self filePath];
    
    if (filePath != nil) {
        ret = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    }
        
    return ret;
}

- (NSString *)filePath
{
    NSString *ret = nil;
    NSArray  *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = ([libraryPaths count] > 0) ? [libraryPaths objectAtIndex:0] : nil;
    
    if (libraryPath != nil) {
        ret = [libraryPath stringByAppendingPathComponent:(NSString *)kSCHBackupPerformedDetectorFileName];
    }
    
    return ret;
}

@end
