//
//  NSFileManager+DoNotBackupExtendedAttribute.m
//  Scholastic
//
//  Created by John Eddie on 20/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "NSFileManager+DoNotBackupExtendedAttribute.h"

#include <sys/xattr.h>

@implementation NSFileManager (DoNotBackupExtendedAttribute)

+ (BOOL)BITsetSkipBackupAttributeToItemAtFilePath:(NSString *)filePath
{
    BOOL ret = NO;
    
    if ([[filePath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        const char *filePathAsChar = [filePath fileSystemRepresentation];
        const char *attributeName = "com.apple.MobileBackup";
        u_int8_t attributeValue = 1;
        
        int result = setxattr(filePathAsChar, attributeName, &attributeValue, sizeof(attributeValue), 0, 0);
        if (result == -1) {
            NSLog(@"Could not set %s on %@, error %d '%s'", attributeName, filePath, errno, strerror(errno));
        } else {
            ret = (result == 0);
        }
    }
    
    return ret;
}

@end