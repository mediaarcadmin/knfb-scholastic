//
//  SCHMakeNullNil.c
//  Scholastic
//
//  Created by John S. Eddie on 04/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHMakeNullNil.h"

static id makeNullNil(id object)
{
    return(object == [NSNull null] ? nil : object);
}
