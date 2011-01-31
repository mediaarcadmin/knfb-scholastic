//
//  SCHCoords.h
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 Zicron Software Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SCHLocationGraphics;

@interface SCHCoords :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * X;
@property (nonatomic, retain) NSNumber * Y;
@property (nonatomic, retain) SCHLocationGraphics * LocationGraphics;

@end



