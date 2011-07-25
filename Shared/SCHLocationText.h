//
//  SCHLocationText.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHHighlight;
@class SCHWordIndex;

// Constants
extern NSString * const kSCHLocationText;

@interface SCHLocationText :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * Page;
@property (nonatomic, retain) SCHWordIndex * WordIndex;
@property (nonatomic, retain) SCHHighlight * Highlight;

@end



