//
//  UNIX2003Remapping.c
//  Scholastic
//
//  Created by John S. Eddie on 30/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

// The test coverage library uses fopen$UNIX2003 and fwrite$UNIX2003 functions
// instead of fopen and fwrite. See
// http://stackoverflow.com/questions/8732393/code-coverage-with-xcode-4-2-missing-files
// for further details.

// Make sure you turn on the “Generate Test Coverage Files” and
// “Instrument Program Flow” in the build settings.

#include <stdio.h>

FILE *fopen$UNIX2003(const char *filename, const char *mode)
{
    return fopen(filename, mode);
}

size_t fwrite$UNIX2003(const void *a, size_t b, size_t c, FILE *d)
{
    return fwrite(a, b, c, d);
}