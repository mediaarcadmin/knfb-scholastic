//
//  SCHLocationGraphics.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHCoords;
@class SCHNote;

@interface SCHLocationGraphics :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * WordIndex;
@property (nonatomic, retain) NSNumber * Page;
@property (nonatomic, retain) SCHNote * Note;
@property (nonatomic, retain) SCHCoords * Coords;

@end



