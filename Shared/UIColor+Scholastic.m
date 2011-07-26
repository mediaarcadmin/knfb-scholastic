//
//  UIColor+Scholastic.m
//  Scholastic
//
//  Created by John S. Eddie on 20/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "UIColor+Scholastic.h"

// Scholastic Color Scheme as described in scholastic_eReader_guide_R7_042911.pdf page 29

@implementation UIColor (UIColorScholastic)

// Hex: #f3f3f4 R: 241 G: 241 B: 242 C: 3 M: 2 Y: 2 K: 0 PMS Warm Grey 1C
+ (UIColor *)SCHGrayColor
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:242.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// A darkened version of SCHGrayColor - not in the eReader guide
+ (UIColor *)SCHGray2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:241.0/255.0*0.8 green:241.0/255.0*0.8 blue:242.0/255.0*0.8 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #d7f1ff R: 215 G: 241 B: 255 C: 14	M: 0 Y: 0 K: 0 PMS 552 C
+ (UIColor *)SCHLightBlue1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:215.0/255.0 green:241.0/255.0 blue:255.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #6acef5 R: 106 G: 206 B: 245 C: 51 M: 1 Y: 1 K: 0 PMS 297 C
+ (UIColor *)SCHLightBlue2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:106.0/255.0 green:206.0/255.0 blue:245.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #00aeef R: 0 G: 174 B: 239 C: 69 M: 14 Y: 0 K: 0 PMS 298 C
+ (UIColor *)SCHBlue1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:0.0 green:174.0/255.0 blue:239.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #0263b6 R: 2 G: 99 B: 182 C: 91 M: 63 Y: 0 K: 0 PMS 2925 C
+ (UIColor *)SCHBlue2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:2.0/255.0 green:99.0/255.0 blue:182.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #00488e R: 0 G: 72 B: 142 C: 100 M: 81 Y: 15 K: 3 PMS 2945 C
+ (UIColor *)SCHBlue3Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:0.0 green:72.0/255.0 blue:142.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #012f5e R: 1 G: 47 B: 94 C: 100 M: 87 Y: 36 K: 28 PMS 295 C
+ (UIColor *)SCHDarkBlue1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:1.0/255.0 green:47.0/255.0 blue:94.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #002e57 R: 0 G: 46 B: 87 C: 100 M: 47 Y: 0 K: 69 PMS 296 C
+ (UIColor *)SCHDarkBlue2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:0.0 green:46.0/255.0 blue:87.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #a700ff R: 167 G: 0	B: 255 C: 58 M: 80 Y: 0 K: 0 PMS 2592 C
+ (UIColor *)SCHPurple1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:167.0/255.0 green:0.0 blue:255.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #5d19a4 R: 93 G: 25 B: 164 C: 79 M: 97 Y: 0 K: 0 PMS 267 C
+ (UIColor *)SCHPurple2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:93.0/255.0 green:25.0/255.0 blue:164.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #00c155 R: 0 G: 193 B: 85 C: 75 M: 0 Y: 91 K: 0 PMS 361 C
+ (UIColor *)SCHGreen1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:0.0 green:193.0/255.0 blue:85.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #9dca2d R: 157 G: 201 B: 45 C: 44 M: 1 Y: 100 K: 0 PMS 367 C
+ (UIColor *)SCHGreen2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:157.0/255.0 green:201.0/255.0 blue:45.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #fff200 R: 255 G: 242 B: 0 C: 4 M: 0 Y: 93 K: 0 PMS 102 C
+ (UIColor *)SCHYellowColor
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:0.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #f7941e R: 247 G: 148 B: 30 C: 0 M: 49 Y: 98 K: 0 PMS 1375 C
+ (UIColor *)SCHOrange1Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:247.0/255.0 green:148.0/255.0 blue:30.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Hex: #f1592a R: 241 G: 90 B: 41 C: 0 M: 80 Y: 93 K: 0 PMS 172 C
+ (UIColor *)SCHOrange2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:241.0/255.0 green:90.0/255.0 blue:41.0/255.0 alpha:1.0] retain];
    });
    
	return(color);
}

// Scholastic Red Hex: #ff0000 R: 255 G: 0 B: 0 C: 0 M: 100 Y: 90 K: 0 PMS 185 C
+ (UIColor *)SCHScholasticRedColor
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:255.0/255.0 green:0.0 blue:0.0 alpha:1.000] retain];
    });
    
	return(color);
}

// Hex: #CF0000 R: 207 G: 0 B: 0 C: 12 M: 100 Y: 100 K: 4 PMS 1797 C
+ (UIColor *)SCHRed2Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:207.0/255.0 green:0.0 blue:0.0 alpha:1.000] retain];
    });
    
	return(color);
}

// Hex: # a70e13 R: 167 G: 14 B: 19 C: 23 M: 100 Y: 100 K: 18 PMS 1807 C
+ (UIColor *)SCHRed3Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:167.0/255.0 green:14.0/255.0 blue:19.0/255.0 alpha:1.000] retain];
    });
    
	return(color);
}

// Hex: # 6d0202 R: 109 G: 2 B: 2 C: 32 M: 100 Y: 100 K: 48 PMS 1815 C 
+ (UIColor *)SCHRed4Color
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:109.0/255.0 green:2.0/255.0 blue:2.0/255.0 alpha:1.000] retain];
    });
    
	return(color);
}

// Hex: #000000 R: 0 G: 0 B: 0 C: 0 M: 0 Y: 0 K: 100 PMS Black C
+ (UIColor *)SCHBlackColor
{
    static dispatch_once_t pred;
	static UIColor *color = nil;
	
    dispatch_once(&pred, ^{
        color = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.000] retain];
    });
    
	return(color);
}

@end
