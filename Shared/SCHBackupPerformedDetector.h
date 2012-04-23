//
//  SCHBackupPerformedDetector.h
//  Scholastic
//
//  Created by John Eddie on 23/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHBackupPerformedDetector : NSObject

- (void)createDetectorIfRequired;
- (void)resetDetectorIfRequired;
- (BOOL)detectorShouldExist;
- (BOOL)detectorExists;

@end
