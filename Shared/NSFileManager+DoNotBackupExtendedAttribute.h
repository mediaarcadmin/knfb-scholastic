//
//  NSFileManager+DoNotBackupExtendedAttribute.h
//  Scholastic
//
//  Created by John Eddie on 20/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DoNotBackupExtendedAttribute)

+ (BOOL)BITsetSkipBackupAttributeToItemAtFilePath:(NSString *)filePath;

@end
