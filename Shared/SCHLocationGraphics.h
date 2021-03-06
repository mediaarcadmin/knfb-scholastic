//
//  SCHLocationGraphics.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHNote;

// Constants
extern NSString * const kSCHLocationGraphics;

@interface SCHLocationGraphics :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * Page;
@property (nonatomic, retain) SCHNote * Note;

- (void)setInitialValues;

@end



