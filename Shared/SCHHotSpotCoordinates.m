//
//  SCHHotSpotCoordinates
//  Scholastic
//
//  Created by John S. Eddie on 13/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHHotSpotCoordinates.h"

#import "USAdditions.h"

@interface SCHHotSpotCoordinates ()

@property (nonatomic, assign) CGPathRef path;

@end

@implementation SCHHotSpotCoordinates

@synthesize rect;
@synthesize path;

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        rect = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    if (path) {
        CGPathRelease(path);
    }
    [super dealloc];
}

#pragma mark - Accessor methods

- (void)setPath:(CGPathRef)newPath
{
    if (newPath != path) {
        if (path) {
            CGPathRelease(path);
        }
        path = CGPathRetain(newPath);
    }
}

#pragma mark - methods

- (void)calculatePathWithText:(NSString *)text
{
    if ([text length] > 0) {
        self.path = parseBase64EncodedPathAndFitToHotSpotRect(text, rect);
    } else {
        self.path = NULL;
    }
}

- (BOOL)containsPoint:(CGPoint)point
{
    BOOL ret = NO;

    if (self.path != NULL) {
        ret = CGPathContainsPoint(self.path, NULL, point, NO);
    } else {
        ret = CGRectContainsPoint(self.rect, point);
    }

    return ret;
}

- (BOOL)intersectsRect:(CGRect)aRect
{
    return CGRectIntersectsRect(self.rect, aRect);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", NSStringFromCGRect(self.rect)];
}

static CGPathRef parseBase64EncodedPathAndFitToHotSpotRect(NSString *text, CGRect hotSpotRect)
{
    CGPathRef pathCopy = nil;
    
    if ([text length] > 0) {
        NSData *data = [NSData dataWithBase64EncodedString:text];
        const uint8_t *bytes = (const uint8_t *)[data bytes];
        int numberOfPoints = [data length] / 4;
        CGPoint *points = (CGPoint *)malloc(sizeof(CGPoint)*numberOfPoints);
        float minx = 0, maxx = 0, miny = 0, maxy = 0;
        if (numberOfPoints > 0) {
            for (NSInteger i = 0; i < numberOfPoints; ++i, bytes += 4) {
                float x = (bytes[0] << 8) + (bytes[1]);
                float y = (bytes[2] << 8) + (bytes[3]);
                points[i] = CGPointMake(x, y);
                if (i == 0) {
                    minx = maxx = x;
                    miny = maxy = y;
                } else {
                    minx = MIN(minx, x);
                    miny = MIN(miny, y);
                    maxx = MAX(maxx, x);
                    maxy = MAX(maxy, y);
                }
            }

            // fit the path inside the hotSpotRect
            CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-minx, -miny);
            CGAffineTransform scale =  CGAffineTransformMakeScale(CGRectGetWidth(hotSpotRect)/(maxx-minx),
                                                                  CGRectGetHeight(hotSpotRect)/(maxy-miny));
            CGAffineTransform trans2 = CGAffineTransformMakeTranslation(CGRectGetMinX(hotSpotRect), CGRectGetMinY(hotSpotRect));
            CGAffineTransform pathTransform = CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);

            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, &pathTransform, points[0].x, points[0].y);
            for (NSInteger i = 1; i < numberOfPoints; ++i) {
                CGPathAddLineToPoint(path, &pathTransform, points[i].x, points[i].y);
            }
            CGPathCloseSubpath(path);
            free(points);

            pathCopy = CGPathCreateCopy(path);
            CGPathRelease(path);
            
            [(id)pathCopy autorelease];
        }
    }

    return pathCopy;
}

@end
