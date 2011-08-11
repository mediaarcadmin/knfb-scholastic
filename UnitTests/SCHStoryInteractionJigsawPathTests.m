//
//  SCHStoryInteractionJigsawPathTests.m
//  Scholastic
//
//  Created by Neil Gall on 11/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "SCHStoryInteractionJigsawPaths.h"

@interface SCHStoryInteractionJigsawPathTests : SenTestCase {}
@end

@implementation SCHStoryInteractionJigsawPathTests

- (SCHStoryInteractionJigsawPaths *)parseFile:(NSString *)filename
{
    NSBundle *unitTestBundle = [NSBundle bundleWithIdentifier:@"com.bitwink.UnitTests"];
    NSString *path = [unitTestBundle pathForResource:filename ofType:@""];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    SCHStoryInteractionJigsawPathTests *paths = [[SCHStoryInteractionJigsawPaths alloc] initWithData:data];
    return [paths autorelease];
}

- (void)testPuzzle6pc
{
    SCHStoryInteractionJigsawPaths *paths = [self parseFile:@"Puzzle-6pc.xaml"];
    STAssertNotNil(paths, @"nil return from parsing Puzzle-6pc");
    
    CGSize size = [paths canvasSize];
    STAssertEqualsWithAccuracy(size.width, 640.645f, 1e-3, @"incorrect canvas width");
    STAssertEqualsWithAccuracy(size.height, 479.909f, 1e-3, @"incorrect canvas height");
    
    STAssertEquals([paths numberOfPaths], 6, @"incorrect path count");

    CGMutablePathRef path0 = CGPathCreateMutable();
    CGPathMoveToPoint(path0, NULL, 427.125,242.441);
    CGPathAddLineToPoint(path0, NULL, 491.488,242.441);
    CGPathAddCurveToPoint(path0, NULL, 507.715,241.693, 520.543,232.188, 520.543,220.574);
    CGPathAddCurveToPoint(path0, NULL, 520.543,207.566, 502.764,202.276, 502.764,189.265);
    CGPathAddCurveToPoint(path0, NULL, 502.764,177.160, 516.698,167.345, 533.880,167.345);
    CGPathAddCurveToPoint(path0, NULL, 551.068,167.345, 565.003,177.160, 565.003,189.265);
    CGPathAddCurveToPoint(path0, NULL, 565.003,202.273, 547.227,207.566, 547.227,220.571);
    CGPathAddCurveToPoint(path0, NULL, 547.227,232.203, 560.097,241.718, 576.353,242.441);
    CGPathAddLineToPoint(path0, NULL, 640.645,242.441);
    CGPathAddLineToPoint(path0, NULL, 640.645,479.909);
    CGPathAddLineToPoint(path0, NULL, 427.125,479.905);
    CGPathAddLineToPoint(path0, NULL, 427.125,433.977);
    CGPathAddLineToPoint(path0, NULL, 427.125,432.664);
    CGPathAddCurveToPoint(path0, NULL, 428.422,418.045, 438.321,406.675, 450.348,406.675);
    CGPathAddCurveToPoint(path0, NULL, 464.219,406.675, 469.854,423.380, 483.729,423.380);
    CGPathAddCurveToPoint(path0, NULL, 496.631,423.380, 507.099,410.287, 507.099,394.144);
    CGPathAddCurveToPoint(path0, NULL, 507.099,377.996, 496.631,364.906, 483.729,364.906);
    CGPathAddCurveToPoint(path0, NULL, 469.854,364.906, 464.219,381.611, 450.348,381.611);
    CGPathAddCurveToPoint(path0, NULL, 438.327,381.611, 428.428,370.251, 427.125,355.642);
    CGPathAddLineToPoint(path0, NULL, 427.125,354.324);
    CGPathAddLineToPoint(path0, NULL, 427.125,242.441);
    CGPathAddLineToPoint(path0, NULL, 427.125,242.441);
    CGPathCloseSubpath(path0);
    
    STAssertTrue(CGPathEqualToPath(path0, [paths pathAtIndex:0]), @"path0 incorrect");
    CGPathRelease(path0);
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGPathMoveToPoint(path1, NULL, 213.613,479.905);
    CGPathAddLineToPoint(path1, NULL, 213.613,390.008);
    CGPathAddCurveToPoint(path1, NULL, 212.810,374.780, 202.691,362.732, 190.315,362.732);
    CGPathAddCurveToPoint(path1, NULL, 176.459,362.732, 170.824,379.427, 156.958,379.427);
    CGPathAddCurveToPoint(path1, NULL, 144.065,379.427, 133.610,366.345, 133.610,350.215);
    CGPathAddCurveToPoint(path1, NULL, 133.610,334.085, 144.065,321.005, 156.958,321.005);
    CGPathAddCurveToPoint(path1, NULL, 170.816,321.005, 176.459,337.694, 190.309,337.694);
    CGPathAddCurveToPoint(path1, NULL, 202.704,337.694, 212.834,325.610, 213.613,310.353);
    CGPathAddLineToPoint(path1, NULL, 213.613,242.445);
    CGPathAddLineToPoint(path1, NULL, 300.845,242.445);
    CGPathAddCurveToPoint(path1, NULL, 316.389,243.678, 328.468,252.965, 328.468,264.242);
    CGPathAddCurveToPoint(path1, NULL, 328.468,277.262, 310.679,282.556, 310.679,295.575);
    CGPathAddCurveToPoint(path1, NULL, 310.679,307.691, 324.627,317.513, 341.816,317.513);
    CGPathAddCurveToPoint(path1, NULL, 359.017,317.513, 372.964,307.688, 372.964,295.575);
    CGPathAddCurveToPoint(path1, NULL, 372.964,282.553, 355.169,277.262, 355.169,264.237);
    CGPathAddCurveToPoint(path1, NULL, 355.169,252.973, 367.233,243.691, 382.754,242.445);
    CGPathAddLineToPoint(path1, NULL, 427.133,242.445);
    CGPathAddLineToPoint(path1, NULL, 427.133,354.440);
    CGPathAddCurveToPoint(path1, NULL, 427.949,369.648, 438.063,381.671, 450.428,381.671);
    CGPathAddCurveToPoint(path1, NULL, 464.285,381.671, 469.920,364.979, 483.778,364.979);
    CGPathAddCurveToPoint(path1, NULL, 496.673,364.979, 507.135,378.059, 507.135,394.188);
    CGPathAddCurveToPoint(path1, NULL, 507.135,410.321, 496.673,423.400, 483.778,423.400);
    CGPathAddCurveToPoint(path1, NULL, 469.920,423.400, 464.285,406.714, 450.428,406.714);
    CGPathAddCurveToPoint(path1, NULL, 438.047,406.714, 427.918,418.767, 427.133,434.003);
    CGPathAddLineToPoint(path1, NULL, 427.133,454.944);
    CGPathAddLineToPoint(path1, NULL, 427.125,454.944);
    CGPathAddLineToPoint(path1, NULL, 427.125,479.905);
    CGPathAddLineToPoint(path1, NULL, 213.613,479.905);
    CGPathAddLineToPoint(path1, NULL, 213.613,479.905);
    CGPathCloseSubpath(path1);

    STAssertTrue(CGPathEqualToPath(path1, [paths pathAtIndex:1]), @"path1 incorrect");
    CGPathRelease(path0);
}

@end
